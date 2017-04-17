////
////  HealthData.swift
////  Your Fat
////
////  Created by Kyle Melton on 4/16/17.
////  Copyright © 2017 Kyle Melton. All rights reserved.
////
//
//import Foundation
//import HealthKit
//
////Fetches the quantity sample data from the health kit.
//class HealthData {
//    
//    //MARK: - Class Properties
//    private let healthStore = HKHealthStore()
//    private let queue = DispatchQueue(label: "com.kalm42.your-fat.hd", attributes: .concurrent)
//    private let group = DispatchGroup()
//    private var bodyMassSamples = [BodyMassSample]()
//    private var bodyFatPercentageSamples = [BodyFatPercentageSample]()
//    var perferredUnitOfMeasurement: UnitOfMeasurement = .lb
//    var isFinishedLoading = false
//    
//    //HealthKit variables
//    private var hkUnitOfMeasurement = HKUnit.pound()
//    private var bodyMassQuantityType: HKQuantityType? = HKObjectType.quantityType(
//        forIdentifier: HKQuantityTypeIdentifier.bodyMass
//    )
//    
//    private var bodyFatPercentageQuantityType: HKQuantityType? = HKObjectType.quantityType(
//        forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage
//    )
//    
//    private var bodyMassSampleType: HKSampleType? = HKObjectType.quantityType(
//        forIdentifier: HKQuantityTypeIdentifier.bodyMass
//    )
//    
//    private var bodyFatPercentageSampleType: HKSampleType? = HKObjectType.quantityType(
//        forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage
//    )
//    
//    //
//    enum HKHealthStoreError: Error {
//        case HealthDataNotAvailable
//        case RequestForAccessNotDisplayed
//    }
//    
//    //init
//    init() {
//        print("Health Data init started")
//        if HKHealthStore.isHealthDataAvailable() {
//            do {
//                try requestAccess()
//            } catch {
//                print("Request for access failed to display to the user and was not previously displayed.")
//            }
//        } else {
//            fatalError("The health store is not available.")
//        }
//        
//        print("Health Data init ended")
//    }
//    
//    //MARK: - Private Functions
//    private func requestAccess() throws {
//        if let bodyMassSampleType = bodyMassSampleType,
//            let bodyFatPercentageSampleType = bodyFatPercentageSampleType,
//            let bodyMassQuantityType = bodyMassQuantityType,
//            let bodyFatPercentageQuantityType = bodyFatPercentageQuantityType
//        {
//            let dataTypesToWrite: Set = [bodyMassSampleType, bodyFatPercentageSampleType]
//            let dataTypesToRead: Set = [bodyMassQuantityType, bodyFatPercentageQuantityType]
//            
//            // Request auth
//            healthStore.requestAuthorization(toShare: dataTypesToWrite, read: dataTypesToRead, completion: successOrError)
//        } else {
//            throw HKHealthStoreError.RequestForAccessNotDisplayed
//        }
//    }
//    
//    private func getPreferredUnits() {
//        if let bodyMass = bodyMassQuantityType {
//            let bodyMassSet: Set<HKQuantityType> = [bodyMass]
//            healthStore.preferredUnits(for: bodyMassSet, completion: unitDictionaryOrError)
//        }
//    }
//    
//    private func successOrError(success: Bool, AuthorizationError: Error?) -> Void {
//        if success {
//            print("Success.")
//            setup()
//        } else {
//            print("Failure.")
//        }
//        if let error = AuthorizationError {
//            print(error)
//        }
//        
//    }
//    
//    // sets the perferredUnitOfMeasurement
//    private func unitDictionaryOrError (unitForQuantityTypeDictionary: [HKQuantityType: HKUnit], preferredUnitError: Error?) -> Void {
//        for (quantityType, unit) in unitForQuantityTypeDictionary {
//            if quantityType == self.bodyMassQuantityType, let preferredUnit = UnitOfMeasurement(rawValue: unit.unitString) {
//                self.hkUnitOfMeasurement = unit
//                self.perferredUnitOfMeasurement = preferredUnit
//            }
//        }
//    }
//    
//    private func getSamplesFromHealthKit(for sampleType: HKSampleType){
//        //1. Set the SampleType to find
//        //  Its a global var bodyFatPercentageSample
//        
//        //2. Write the query, date range, and all other options for the query
//        //2a. Dates
//        let endDate = Date() //now
//        let startDate = Date(timeIntervalSinceNow: -TimeLengthInSeconds.oneYear.rawValue)
//        
//        //2b. Query Options
//        let queryOptions = HKQueryOptions()
//        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: queryOptions)
//        
//        //3. How many results can be returned.
//        let resultLimit = Int(HKObjectQueryNoLimit)
//        
//        //4. Run this bitch
//        let query = HKSampleQuery(
//            sampleType: sampleType, predicate: predicate, limit: resultLimit, sortDescriptors: nil, resultsHandler: convertHealthKitSample
//        )
//        self.healthStore.execute(query)
//    }
//    private func convertHealthKitSample(query: HKSampleQuery, samples: [HKSample]?, error: Error?) -> Void {
//        queue.async {
//            self.group.enter()
//            guard let samples = samples as? [HKQuantitySample] else {
//                fatalError("Failed to downcast health kit samples to hk quantity samples")
//            }
//            for sample in samples {
//                let quantity = sample.quantity
//                if quantity.is(compatibleWith: HKUnit.percent()) {
//                    //is body fat percentage
//                    let value = quantity.doubleValue(for: HKUnit.percent())
//                    let date = sample.endDate
//                    let bodyFat = BodyFatPercentageSample(date: date, value: value)
//                    self.bodyFatPercentageSamples.insert(bodyFat, at: 0)
//                } else {
//                    //is body mass
//                    let value = quantity.doubleValue(for: self.hkUnitOfMeasurement)
//                    let date = sample.endDate
//                    let bodyMass = BodyMassSample(date: date, value: value, unit: self.perferredUnitOfMeasurement)
//                    self.bodyMassSamples.insert(bodyMass, at: 0)
//                }
//            }
//        }
//    }
//    private func setup() -> Void {
//        print("Health Data setup started.")
//        getPreferredUnits()
//        queue.async {
//            print("Fetching body mass samples.")
//            if let bodyMassSampleType = self.bodyMassSampleType {
//                self.getSamplesFromHealthKit(for: bodyMassSampleType)
//            }
//        }
//        queue.async {
//            print("Fetching body fat percentages")
//            if let bodyFatPercentageSampleType = self.bodyFatPercentageSampleType {
//                self.getSamplesFromHealthKit(for: bodyFatPercentageSampleType)
//            }
//        }
//        group.notify(queue: .main){
//            print("Done loading body mass and body fat.")
//            self.isFinishedLoading = true
//        }
//        print("Health Data setup block ended.")
//    }
//    private func sortSamples(samples: [FatMassSample]?) -> [FatMassSample] {
//        var sorted: [FatMassSample] = []
//        var i = 0
//        
//        if let samples = samples {
//            while i < samples.count {
//                var j = 0
//                while j < sorted.count {
//                    if samples[i].date > sorted[j].date {
//                        break
//                    }
//                    
//                    j += 1
//                }
//                sorted.insert(samples[i], at: j)
//                i += 1
//            }
//        }
//        return sorted
//    }
//    
//    private func convertUnitToHKUnit(_ unit: UnitOfMeasurement) -> HKUnit {
//        switch unit {
//        case .g:
//            return HKUnit.gram()
//        case .kg:
//            return HKUnit.gramUnit(with: HKMetricPrefix.kilo)
//        case .lb:
//            return HKUnit.pound()
//        case .percent:
//            return HKUnit.percent()
//        }
//    }
//    
//    //MARK: - Public Methods
//    func record(_ fatMass: FatMassSample){
//        //The array to submit to HealthKit
//        var samples: [HKObject] = []
//        
//        //
//        let bodyMassValue = fatMass.bodyMass.value
//        let bodyMassHKUnit = convertUnitToHKUnit(fatMass.bodyMass.unit)
//        let date = fatMass.bodyMass.date
//        let bodyFatPercentageValue = fatMass.bodyFatPercentage.value
//        
//        
//        // Add the body mass to the array.
//        if let bodyMassQuantityType = self.bodyMassQuantityType {
//            let bodyMassQuantity = HKQuantity(unit: bodyMassHKUnit, doubleValue: bodyMassValue)
//            samples.append(
//                HKQuantitySample(type: bodyMassQuantityType, quantity: bodyMassQuantity, start: date, end: date)
//            )
//        }
//        
//        // Add the body fat percentage to the array.
//        if let bodyFatPercentageQuantityType = self.bodyFatPercentageQuantityType {
//            let bodyFatPercentageQuantity = HKQuantity(unit: HKUnit.percent(), doubleValue: bodyFatPercentageValue)
//            samples.append(
//                HKQuantitySample(type: bodyFatPercentageQuantityType, quantity: bodyFatPercentageQuantity, start: date, end: date)
//            )
//        }
//        
//        // Now that everything is packaged up, send the array to the health kit for saving.
//        healthStore.save(samples, withCompletion: successOrError)
//    }
//    
//    func getFatMassSamples() -> [FatMassSample] {
//        var fatMassSamples = [FatMassSample]()
//        
//        //BodyMass array trackers.
//        var i: Int = 0
//        let bodyMassArrayLimit = bodyMassSamples.count
//        
//        //BodyFat% array trackers.
//        var j: Int = 0
//        let bodyFatPercentageArrayLimit = bodyFatPercentageSamples.count
//        
//        //Count will be the larger of the two arrays. Inside the loop we will ensure that the index is still inbounds before attempting to access the array
//        let count = bodyMassArrayLimit > bodyFatPercentageArrayLimit ? bodyMassArrayLimit : bodyFatPercentageArrayLimit
//        
//        //Loop through and find matching records.
//        while i < count {
//            
//            //Are we inbounds of both bodyMass and bodyFat?
//            if i < bodyMassArrayLimit && j < bodyFatPercentageArrayLimit {
//                
//                //setup date variables for better readability
//                let bfDateHigh = bodyFatPercentageSamples[j].date + TimeLengthInSeconds.oneHour.rawValue
//                let bfDateLow = bodyFatPercentageSamples[j].date - TimeLengthInSeconds.oneHour.rawValue
//                let bmDate = bodyMassSamples[i].date
//                
//                // bodyMassSamples[i].date <= bodyFatPercentageSamples[j].date+1hour && >= bf%s-1hour
//                if bmDate <= bfDateHigh && bmDate >= bfDateLow {
//                    
//                    //We have a match, make a fat mass sample, and add it to the array.
//                    let fms = FatMassSample(bodyMass: bodyMassSamples[i], bodyFatPercentage: bodyFatPercentageSamples[j])
//                    
//                    //now add it to the array
//                    fatMassSamples.insert(fms, at: 0)
//                    
//                    //Increment the index trackers.
//                    i += 1  //increment the bodyMass sample index tracker.
//                    j += 1  //incrememnt the body fat percentage index tracker.
//                    
//                } else if bmDate > bodyFatPercentageSamples[j].date {
//                    // The body mass sample occured before the body fat sample date.
//                    i += 1 //increment body mass sample index tracker.
//                    
//                } else {
//                    // The body mass sample date occured after the body fat percentage sample.
//                    j += 1  //increment the bf% index tracker.
//                }
//                
//            } else {
//                break
//            }
//        }
//        
//        fatMassSamples = sortSamples(samples: fatMassSamples)
//        
//        return fatMassSamples
//    }
//    
//}
