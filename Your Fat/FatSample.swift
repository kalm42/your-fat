//
//  FatSample.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/1/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

//To ensure I don't typo a unit, cause that'd be bad
enum UnitOfMeasurement: String {
    case lb
    case kg
    case g
    case percent
    
    static func fromHK(hk: HKUnit) throws -> UnitOfMeasurement {
        if hk.unitString == HKUnit.pound().unitString {
            return .lb
        } else if hk.unitString == HKUnit.gramUnit(with: .kilo).unitString {
            return .kg
        } else if hk.unitString == HKUnit.gram().unitString {
            return .g
        } else if hk.unitString == HKUnit.percent().unitString {
            return .percent
        } else {
            throw UnitError.NotAUnitMeasured
        }
    }
    
    enum UnitError: Error {
        case NotAUnitMeasured
    }
}


//all samples need these
protocol Sample: Hashable {
    var date: Date { get set }
    var value: Double { get set }
    var unit: UnitOfMeasurement { get set }
    
    var hashValue: Int { get }
    static func ==(lhs: Self, rhs: Self) -> Bool
    
}

struct BodyFatPercentageSample: Sample {
    var date: Date
    var value: Double
    var unit: UnitOfMeasurement = UnitOfMeasurement.percent
    var hashValue: Int { return Int(value*100) }
    
    init(date: Date, value: Double) {
        self.date = date
        self.value = value
    }
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

struct BodyMassSample: Sample {
    var date: Date
    var value: Double
    var unit: UnitOfMeasurement
    var hashValue: Int { return Int(value) }
    
    init(date: Date, value: Double, unit: UnitOfMeasurement) {
        self.date = date
        self.value = value
        self.unit = unit
    }
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
