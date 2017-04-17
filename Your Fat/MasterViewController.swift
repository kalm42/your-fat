//
//  MasterViewController.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/1/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit
import HealthKit

class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    let dataSource = FatSampleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        if HKHealthStore.isHealthDataAvailable() {
            HealthKitAPI.requestAccess()
        }
        if HealthKitAPI.hasAccess() {
            self.getBodyMassSamples()
            self.getBodyFatPercentageSamples()
        }
        self.group.notify(queue: .main) {
            self.makeFatMassSamples()
            self.tableView.reloadData()
        }
        
        //Add the edit button
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        //Set the data source
        tableView.dataSource = dataSource
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let sample = dataSource.samples[indexPath.row]
                
                guard let navigationController = segue.destination as? UINavigationController, let sampleDetailController = navigationController.topViewController as? DetailViewController else { return }
                
                sampleDetailController.fatSample = sample
            }
        } else if segue.identifier == "addFromMasterView" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddViewController
            controller.selectedIndex = selectPerferredUnitOfMeasurement()
        }
    }
    
    private func selectPerferredUnitOfMeasurement() -> Int {
        let unit = try! UnitOfMeasurement.fromHK(hk: HealthKitAPI.preferredUnit)
        switch unit {
        case .g:
            fatalError("Not setup to hangle weight in grams")
        case .kg:
            return 0
        case .lb:
            return 1
        case .percent:
            fatalError("Body weight should not be measured in percent.")
        }
    }
    
    @IBAction func unwindAddView(unwindSegue: UIStoryboardSegue) {
        //If the segue's source that is unwinding can be downcast to the AddViewController, then attempt to save the
        if let sourceViewController = unwindSegue.source as? AddViewController {
            let unit = sourceViewController.uom
            let date = sourceViewController.date
            if let x = sourceViewController.bodyMassTextField.text, let y = sourceViewController.bodyFatPercentageTextField.text {
                let bm = Double(x)
                let bf = Double(y)
                if let bmvalue = bm, let bfvalue = bf {
                    let bms = BodyMassSample(date: date, value: bmvalue, unit: unit)
                    let bfs = BodyFatPercentageSample(date: date, value: (bfvalue / 100))
                    let fms = FatMassSample(bodyMass: bms, bodyFatPercentage: bfs)
                    //Persist the data in the health kit
                    HealthKitAPI.record(fms)
                    
                    //Add this data to the data model for the display.
                    dataSource.samples.insert(fms, at: 0)
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    //MARK: - HealthStore
    let bodyMassQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyMass)!
    let bodyFatPercentageQuantityType: HKQuantityType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.bodyFatPercentage)!
    let queue = DispatchQueue(label: "com.kalm42.app.your-fat.fsds", attributes: .concurrent)
    let group = DispatchGroup()
    
    var hkBodyMassSamples: [HKQuantitySample] = []
    var hkBodyPercentageSamples: [HKQuantitySample] = []
    
    func getBodyMassSamples() {
        getSamplesFromHealthKit(for: self.bodyMassQuantityType)
        for hkBodyMassSample in self.hkBodyMassSamples {
            let bodyMassSample = BodyMassSample(sample: hkBodyMassSample, unit: HealthKitAPI.preferredUnit)
            dataSource.bodyMassSamples.insert(bodyMassSample, at: 0)
        }
    }
    func getBodyFatPercentageSamples() {
        getSamplesFromHealthKit(for: self.bodyFatPercentageQuantityType)
        for hkBodyFatPercentageSample in self.hkBodyPercentageSamples {
            let bodyFatPercentageSample = BodyFatPercentageSample(sample: hkBodyFatPercentageSample)
            dataSource.bodyFatPercentageSamples.insert(bodyFatPercentageSample, at: 0)
        }
    }
    
    func getSamplesFromHealthKit(for sampleType: HKSampleType){
        let endDate = Date() //now
        let startDate = Date(timeIntervalSinceNow: -TimeLengthInSeconds.oneYear.rawValue)
        
        //2b. Query Options
        let queryOptions = HKQueryOptions()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: queryOptions)
        
        //3. How many results can be returned.
        let resultLimit = Int(HKObjectQueryNoLimit)
        
        //4. Run this
        let query = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: resultLimit, sortDescriptors: nil) { (query: HKSampleQuery, samples: [HKSample]?, error: Error?) in
            self.queue.async {
                self.group.enter()
                guard let qSamples = samples as? [HKQuantitySample] else {
                    fatalError("Failed to downcast health kit samples to quantity samples")
                }
                if sampleType.isEqual(self.bodyFatPercentageQuantityType) {
                    self.hkBodyPercentageSamples.append(contentsOf: qSamples)
                    self.makeBodyFatPercentageSamples()
                } else {
                    self.hkBodyMassSamples.append(contentsOf: qSamples)
                    self.makeBodyMassSamples()
                }
            }
        }
        dataSource.healthStore.execute(query)
    }
    
    func makeBodyFatPercentageSamples() {
        for hkBodyFatPercentageSample in hkBodyPercentageSamples {
            let bfs = BodyFatPercentageSample(sample: hkBodyFatPercentageSample)
            dataSource.bodyFatPercentageSamples.insert(bfs, at: 0)
        }
    }
    func makeBodyMassSamples(){
        for hkBodyMassSample in hkBodyMassSamples {
            let bms = BodyMassSample(sample: hkBodyMassSample, unit: HealthKitAPI.preferredUnit)
            dataSource.bodyMassSamples.insert(bms, at: 0)
        }
    }
    
    func makeFatMassSamples() {
        //BodyMass array trackers.
        var i: Int = 0
        let bodyMassArrayLimit = dataSource.bodyMassSamples.count
        
        //BodyFat% array trackers.
        var j: Int = 0
        let bodyFatPercentageArrayLimit = dataSource.bodyFatPercentageSamples.count
        
        //Count will be the larger of the two arrays. Inside the loop we will ensure that the index is still inbounds before attempting to access the array
        let count = bodyMassArrayLimit > bodyFatPercentageArrayLimit ? bodyMassArrayLimit : bodyFatPercentageArrayLimit
        
        //Loop through and find matching records.
        while i < count {
            
            //Are we inbounds of both bodyMass and bodyFat?
            if i < bodyMassArrayLimit && j < bodyFatPercentageArrayLimit {
                
                //setup date variables for better readability
                let bfDateHigh = dataSource.bodyFatPercentageSamples[j].date + TimeLengthInSeconds.oneHour.rawValue
                let bfDateLow = dataSource.bodyFatPercentageSamples[j].date - TimeLengthInSeconds.oneHour.rawValue
                let bmDate = dataSource.bodyMassSamples[i].date
                
                // bodyMassSamples[i].date <= bodyFatPercentageSamples[j].date+1hour && >= bf%s-1hour
                if bmDate <= bfDateHigh && bmDate >= bfDateLow {
                    
                    //We have a match, make a fat mass sample, and add it to the array.
                    let fms = FatMassSample(bodyMass: dataSource.bodyMassSamples[i], bodyFatPercentage: dataSource.bodyFatPercentageSamples[j])
                    
                    //now add it to the array
                    dataSource.samples.insert(fms, at: 0)
                    
                    //Increment the index trackers.
                    i += 1  //increment the bodyMass sample index tracker.
                    j += 1  //incrememnt the body fat percentage index tracker.
                    
                } else if bmDate > dataSource.bodyFatPercentageSamples[j].date {
                    // The body mass sample occured before the body fat sample date.
                    i += 1 //increment body mass sample index tracker.
                    
                } else {
                    // The body mass sample date occured after the body fat percentage sample.
                    j += 1  //increment the bf% index tracker.
                }
                
            } else {
                break
            }
        }
    }

}

