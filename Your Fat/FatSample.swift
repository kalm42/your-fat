//
//  FatSample.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/1/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

//all samples need these
protocol Sample {
    var date: Date { get set }
    var value: Double { get set }
    var unit: UnitOfMeasurement { get set }
    
    static func ==(lhs: Self, rhs: Self) -> Bool
    
}

struct FatMassSample {
    var bodyMass: BodyMassSample
    var bodyFatPercentage: BodyFatPercentageSample
    
    var date: Date {
        return bodyMass.date
    }
    var value: Double {
        return bodyMass.value * bodyFatPercentage.value
    }
    var unit: UnitOfMeasurement {
        return bodyMass.unit
    }
    
    init(bodyMass: BodyMassSample, bodyFatPercentage: BodyFatPercentageSample) {
        self.bodyMass = bodyMass
        self.bodyFatPercentage = bodyFatPercentage
    }
}
