//
//  GlobalFunctions.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/18/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import Foundation

//Because who'd remember that shit
enum TimeLengthInSeconds: TimeInterval {
    case oneHour = 3600 //1 hour 3600 seconds
    case oneDay = 86400 //1 day	86400 seconds
    case oneWeek = 604800 //1 week	604800 seconds
    case oneMonth = 2629743 //1 month (30.44 days) 	2629743 seconds
    case oneYear = 31556926 //1 year (365.24 days) 	 31556926 seconds
}

//Common task
func formatDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeStyle = .short
    
    return dateFormatter.string(from: date)
}
