////
////  FatSampleDataSource.swift
////  Your Fat
////
////  Created by Kyle Melton on 4/16/17.
////  Copyright © 2017 Kyle Melton. All rights reserved.
////
//
//import UIKit
//import HealthKit
//
//class FatSampleDataSource: NSObject, UITableViewDataSource {
//    
//    private var samples: [FatMassSample]
//    
//    init(samples: [FatMassSample]) {
//        self.samples = samples
//    }
//    
//    //MARK: - Data
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        //Instantiate cell
//        let cell = tableView.dequeueReusableCell(withIdentifier: "FatSampleCell", for: indexPath) as! FatMassTableViewCell
//        
//        //Setup and configure cell.
//        let sample = samples[indexPath.row]
//        
//        cell.fatMassLabel.text = "\(sample.value) \(sample.unit)"
//        cell.bodyCompositionLabel.text = "(\(sample.bodyMass.value) \(sample.bodyMass.unit) at \(sample.bodyFatPercentage.value*100)% bf)"
//        return cell
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return samples.count
//    }
//}
