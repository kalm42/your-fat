//
//  BodyFatPercentageSample.swift
//  Your Fat
//
//  Created by Kyle Melton on 5/2/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

struct BodyFatPercentageSample: Sample {
    var date: Date
    var value: Double
    var unit: UnitOfMeasurement = UnitOfMeasurement.percent
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
}

extension BodyFatPercentageSample {
    init(sample: HKQuantitySample) {
        let quantity = sample.quantity
        guard quantity.is(compatibleWith: HKUnit.percent()) else { fatalError("Non bf% sample given") }
        self.date = sample.endDate
        self.value = quantity.doubleValue(for: HKUnit.percent())
    }
    
    //MARK: Functions
    static func ==(lhs: BodyFatPercentageSample, rhs: BodyFatPercentageSample) -> Bool {
        if lhs.date == rhs.date && lhs.value == rhs.value && lhs.unit == rhs.unit {
            return true
        } else {
            return false
        }
    }
}


