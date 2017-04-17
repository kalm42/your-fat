////
////  FatSampleSource.swift
////  Your Fat
////
////  Created by Kyle Melton on 4/16/17.
////  Copyright © 2017 Kyle Melton. All rights reserved.
////
//
//import Foundation
//
//class FatSampleSource {
//    static var fatSamples: [FatMassSample] {
//        let healthKitAPI = HealthKitAPI()
//        //Empty arrays
//        let fatMassSamples:[FatMassSample] = []
//        var bodyMassSamples:[BodyMassSample] = []
//        var bodyFatPercentageSamples:[BodyFatPercentageSample] = []
//        
//        //Get raw data from the health kit
//        let hkBodyMassSamples = healthKitAPI.getBodyMassSamples()
//        let hkBodyFatPercentageSamples = healthKitAPI.getBodyFatPercentageSamples()
//        
//        for hkBodyMassSample in hkBodyMassSamples {
//            let bodyMassSample = BodyMassSample(sample: hkBodyMassSample, unit: HealthKitAPI.preferredUnit)
//            bodyMassSamples.insert(bodyMassSample, at: 0)
//        }
//        for hkBodyFatPercentageSample in hkBodyFatPercentageSamples {
//            let bodyFatPercentageSample = BodyFatPercentageSample(sample: hkBodyFatPercentageSample)
//            bodyFatPercentageSamples.insert(bodyFatPercentageSample, at: 0)
//        }
//        
//        return fatMassSamples
//    }
//}
