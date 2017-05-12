//
//  BodyMassSample.swift
//  Your Fat
//
//  Created by Kyle Melton on 5/2/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

struct BodyMassSample: Sample {
    var date: Date
    var value: Double
    var unit: UnitOfMeasurement
}

extension BodyMassSample {
    init(sample: HKQuantitySample, unit: HKUnit) {
        self.unit = try! UnitOfMeasurement.fromHK(hk: unit)
        let quantity = sample.quantity
        self.date = sample.endDate
        self.value = quantity.doubleValue(for: unit)
    }
    
    //MARK: Functions
    static func ==(lhs: BodyMassSample, rhs: BodyMassSample) -> Bool {
        if lhs.date == rhs.date && lhs.value == rhs.value && lhs.unit == rhs.unit {
            return true
        } else { return false }
    }
}


