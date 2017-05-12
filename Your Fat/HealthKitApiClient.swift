//
//  HealthKitApiClient.swift
//  Your Fat
//
//  Created by Kyle Melton on 5/2/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

enum HealthKitApiClientError {
    case queryFailedToGet(String)
    case failedToGetTheStore
}

class HealthKitApiClient {
    
    // MARK: - Properties
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    private let hkUnitOfMeasurement = HKUnit.pound()
    private let bodyMassQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private let bodyFatPercentageQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    private let bodyMassSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private let bodyFatPercentageSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    
    
    
    // MARK: - Get Functions
    func getSamples(from startDate: Date, to endDate: Date, sampleType: HKSampleType, completionHandler completion: @escaping ([HKQuantitySample]?, HealthKitApiClientError?) -> Void) {
        guard let healthStore = appDelegate?.healthStore else {
            completion(nil, .failedToGetTheStore)
            return
        }
        
        // Query Options
        let queryOptions = HKQueryOptions()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: queryOptions)
        
        // How many results can be returned.
        let resultLimit = Int(HKObjectQueryNoLimit)
        
        let sortBy = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        
        // Run this
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: resultLimit, sortDescriptors: [sortBy]) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
            
            if let samples = samples as? [HKQuantitySample] {
                completion(samples, nil)
            } else {
                print("HealthKitApiClientError.queryFailedToGet(\"\(sampleType))")
                completion(nil, HealthKitApiClientError.queryFailedToGet("\(sampleType)"))
            }
        }
        healthStore.execute(query)
        
    }

    /*
     Helper functions
     */
    func hasAccess() -> Bool {
        let hs = HKHealthStore()
        let bmst: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let bfpst: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
        
        let bodyMassAuthStatus = hs.authorizationStatus(for: bmst)
        let bfAuthStatus = hs.authorizationStatus(for: bfpst)
        
        if bodyMassAuthStatus == .sharingAuthorized && bfAuthStatus == .sharingAuthorized {
            return true
        } else {
            return false
        }
    }
    
    /***************************************************************************
     
     */
    func record(_ fatMass: FatMassSample){
        //The array to submit to HealthKit
        var samples: [HKObject] = []
        
        //
        let bodyMassValue = fatMass.bodyMass.value
        let bodyMassHKUnit = self.convertUnitToHKUnit(fatMass.bodyMass.unit)
        let date = fatMass.bodyMass.date
        let bodyFatPercentageValue = fatMass.bodyFatPercentage.value
        
        
        // Add the body mass to the array.
        let bodyMassQuantity = HKQuantity(unit: bodyMassHKUnit, doubleValue: bodyMassValue)
        samples.append(HKQuantitySample(type: bodyMassQuantityType, quantity: bodyMassQuantity, start: date, end: date))
        
        // Add the body fat percentage to the array.
        let bodyFatPercentageQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: bodyFatPercentageValue)
        samples.append(
            HKQuantitySample(type: bodyFatPercentageQuantityType, quantity: bodyFatPercentageQuantity, start: date, end: date)
        )
        
        // Now that everything is packaged up, send the array to the health kit for saving.
        guard let healthStore = appDelegate?.healthStore else { return }
        healthStore.save(samples) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("Saved")
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    /***************************************************************************
     
     */
    private func convertUnitToHKUnit(_ unit: UnitOfMeasurement) -> HKUnit {
        switch unit {
        case .g:
            return HKUnit.gram()
        case .kg:
            return HKUnit.gramUnit(with: HKMetricPrefix.kilo)
        case .lb:
            return HKUnit.pound()
        case .percent:
            return HKUnit.percent()
        }
    }
    
    /***************************************************************************
     
     */
    func requestAccess() {
        let dataTypesToWrite: Set = [bodyMassSampleType, bodyFatPercentageSampleType]
        let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
        // Request auth
        guard let healthStore = appDelegate?.healthStore else { return }
        healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { (isSuccess:Bool, error:Error?) in
            if isSuccess {
                print("The authorization for HealthKit access was shown to the user.")
                
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    /***************************************************************************
     
     */
    public func getPreferredUnit() -> HKUnit {
        var unitToReturn: HKUnit = HKUnit.pound()
        let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
        
        guard let healthStore = appDelegate?.healthStore else { return unitToReturn }
        healthStore.preferredUnits(for: dataTypesToRead) { (dictionary: [HKQuantityType : HKUnit], error:Error?) in
            for (_, unit) in dictionary {
                if unit.unitString != HKUnit.percent().unitString {
                    unitToReturn = unit
                }
            }
        }
        return unitToReturn
    }
    
    /***************************************************************************
     Get access to the heal kit.
     */
    func getHealthKitAccess(completion: @escaping (Bool) -> Void) {
        let bodyMassQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let bodyFatPercentageQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
        let bodyMassSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
        let bodyFatPercentageSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
        
        let dataTypesToWrite: Set = [bodyMassSampleType, bodyFatPercentageSampleType]
        let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
        
        // Request auth
        guard let healthStore = appDelegate?.healthStore else { return }
        healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { (isSuccess:Bool, error:Error?) in
            if isSuccess {
                print("The authorization for HealthKit access was shown to the user.")
                completion(isSuccess)
            }
            if let error = error {
                print(error)
                completion(false)
            }
        }
    }



    
}

