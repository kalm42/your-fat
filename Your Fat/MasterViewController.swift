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
    var fms = [FatMassSample]()
    let client = HealthKitApiClient()
    let source = FatSampleSource()

    override func viewDidLoad() {
        print("MasterViewController: viewDidLoad()")
        loadData()
        
        super.viewDidLoad()
    }
    
    func loadData() {
        if HKHealthStore.isHealthDataAvailable() {
            print("MasterViewController: Health Data is available")
            client.getHealthKitAccess() { success in
                print("MasterViewController: getHKAccess completionhandler")
                if success {
                    print("Access requested.")
                    //check for access
                    if self.client.hasAccess() {
                        let source = FatSampleSource()
                        source.getSamples() { fatMass, error in
                            if let fatMass = fatMass {
                                self.fms.append(contentsOf: fatMass)
                                self.tableView.reloadData()
                            }
                        }
                    }
                    
                } else {
                    print("Access not requested.")
                }
            }
            if client.hasAccess() && fms.count < 1 {
                source.getSamples() { fatMass, error in
                    if let fatMass = fatMass {
                        self.fms.append(contentsOf: fatMass)
                        self.tableView.reloadData()
                    }
                    if let error = error {
                        print(error)
                    }
                    
                }
            }
        } else {
            print("No health data available")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Data Source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Instantiate cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "FatSampleCell", for: indexPath) as! FatMassTableViewCell
        
        //Setup and configure cell.
        let sample = fms[indexPath.row]
        
        cell.fatMassLabel.text = "\(sample.value) \(sample.unit)"
        cell.bodyCompositionLabel.text = "(\(sample.bodyMass.value) \(sample.bodyMass.unit) at \(sample.bodyFatPercentage.value*100)% bf)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fms.count
    }

    
    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let sample = fms[indexPath.row]
                
                guard let navigationController = segue.destination as? UINavigationController, let sampleDetailController = navigationController.topViewController as? DetailViewController else { return }
                
                sampleDetailController.fatSample = sample
            }
        } else if segue.identifier == "addFromMasterView" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddViewController
            controller.selectedIndex = selectPerferredUnitOfMeasurement()
        }
    }
    
    private func selectPerferredUnitOfMeasurement() -> Int {
        let unit = try! UnitOfMeasurement.fromHK(hk: client.getPreferredUnit())
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
                    client.record(fms)
                    
                    
                    
                    //Add this data to the data model for the display.
                    self.fms.insert(fms, at: 0)
                    
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}

