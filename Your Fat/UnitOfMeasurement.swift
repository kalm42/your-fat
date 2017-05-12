//
//  UnitOfMeasurement.swift
//  Your Fat
//
//  Created by Kyle Melton on 5/2/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation
import HealthKit

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

