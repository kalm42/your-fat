//
//  FatSampleDataSource.swift
//  Your Fat
//
//  Created by Kyle Melton on 4/16/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit
import HealthKit

class FatSampleDataSource: NSObject, UITableViewDataSource {
    
    var bodyMassSamples: [BodyMassSample] = []
    var bodyFatPercentageSamples: [BodyFatPercentageSample] = []
    var samples: [FatMassSample] = []
    let healthStore = HKHealthStore()
    
    //MARK: - Data
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Instantiate cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FatSampleCell", for: indexPath) as? FatMassTableViewCell else { fatalError() }
        //Setup and configure cell.
        let sample = samples[indexPath.row]
        cell.fatMassLabel.text = "\(sample.value) \(sample.unit)"
        cell.bodyCompositionLabel.text = "(\(sample.bodyMass.value) \(sample.bodyMass.unit) at \(sample.bodyFatPercentage.value*100)% bf)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    
    //MARK: - Editing
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            samples.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
}
