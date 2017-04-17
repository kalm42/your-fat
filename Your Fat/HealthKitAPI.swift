//
//  HealthKitAPI.swift
//  Your Fat
//
//  Created by Kyle Melton on 4/16/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitAPI {
    
    //MARK: - Static Functions & Variables
    public static var preferredUnit: HKUnit {
        get {
            var unitToReturn: HKUnit = HKUnit.pound()
            let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
            healthStore.preferredUnits(for: dataTypesToRead) { (dictionary: [HKQuantityType : HKUnit], error:Error?) in
                for (_, unit) in dictionary {
                    if unit.unitString != HKUnit.percent().unitString {
                        unitToReturn = unit
                    }
                }
            }
            return unitToReturn
        }
    }
    //Properties
    private static let healthStore = HKHealthStore()
    //HealthKit variables
    private static let hkUnitOfMeasurement = HKUnit.pound()
    private static let bodyMassQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private static let bodyFatPercentageQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    private static let bodyMassSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private static let bodyFatPercentageSampleType: HKSampleType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    
    static func requestAccess() {
        let dataTypesToWrite: Set = [bodyMassSampleType, bodyFatPercentageSampleType]
        let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
        // Request auth
        healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead) { (isSuccess:Bool, error:Error?) in
            if isSuccess {
                print("The authorization for HealthKit access was shown to the user.")
                
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    static func hasAccess() -> Bool {
        let bodyMassAuthStatus = healthStore.authorizationStatus(for: bodyMassSampleType)
        let bfAuthStatus = healthStore.authorizationStatus(for: bodyFatPercentageSampleType)
        if bodyMassAuthStatus == .sharingAuthorized && bfAuthStatus == .sharingAuthorized {
            return true
        } else {
            return false
        }
    }
    
    static func record(_ fatMass: FatMassSample){
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
        self.healthStore.save(samples) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("Saved")
            }
            if let error = error {
                print(error)
            }
        }
    }
    
    
    //MARK: - Instance functions & Variables
    private let queue = DispatchQueue(label: "com.kalm42.app.your-fat.mvc", attributes: .concurrent)
    public let group = DispatchGroup()
    private let bodyMassQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    private let bodyFatPercentageQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    
    func getBodyMassSamples() -> [HKQuantitySample] {
        return getSamplesFromHealthKit(for: self.bodyMassQuantityType)
    }
    func getBodyFatPercentageSamples() -> [HKQuantitySample] {
        return getSamplesFromHealthKit(for: self.bodyFatPercentageQuantityType)
    }
    
    private  func getSamplesFromHealthKit(for sampleType: HKSampleType) -> [HKQuantitySample]{
        //Property to return
        var quanitySamples: [HKQuantitySample] = []
        
        let endDate = Date() //now
        let startDate = Date(timeIntervalSinceNow: -TimeLengthInSeconds.oneYear.rawValue)
        
        //2b. Query Options
        let queryOptions = HKQueryOptions()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: queryOptions)
        
        //3. How many results can be returned.
        let resultLimit = Int(HKObjectQueryNoLimit)
        
        //4. Run this
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: resultLimit, sortDescriptors: nil) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
            self.queue.async {
                self.group.enter()
                guard let qSamples = samples as? [HKQuantitySample] else {
                    fatalError("Failed to downcast health kit samples to quantity samples")
                }
                
                quanitySamples.append(contentsOf: qSamples)
            }
        }
        HealthKitAPI.healthStore.execute(query)
        return quanitySamples
    }
    
    private static func convertUnitToHKUnit(_ unit: UnitOfMeasurement) -> HKUnit {
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

}

