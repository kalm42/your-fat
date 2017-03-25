//
//  MasterViewController.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/1/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit

class FatMassTableViewCell: UITableViewCell {
    @IBOutlet weak var fatMassLabel: UILabel!
    @IBOutlet weak var bodyCompositionLabel: UILabel!
}

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var healthData = HealthData()
    var samples: [FatMassSample] = []
    let queue = DispatchQueue(label: "com.kalm42.Your-Fat.mvc", attributes: .concurrent)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        

        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        while self.healthData.isFinishedLoading {
            sleep(1)
        }
        self.samples.append(contentsOf: self.healthData.getFatMassSamples())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let sample = samples[indexPath.row]
                let controller = segue.destination as! DetailViewController
                controller.bfLabelText = "\(sample.bodyFatPercentage.value)%"
                controller.bwLabelText = "\(sample.bodyMass.value) \(sample.bodyMass.unit)"
            }
        } else if segue.identifier == "addFromMasterView" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddViewController
            controller.selectedIndex = selectPerferredUnitOfMeasurement()
        }
    }
    
    private func selectPerferredUnitOfMeasurement() -> Int {
        switch healthData.perferredUnitOfMeasurement {
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
                    healthData.record(fms)
                    
                    //Add this data to the data model for the display.
                    samples.insert(fms, at: 0)
                    let indexPath = IndexPath(row: 0, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .automatic)
                }
            }
        }
        
    }
    

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? FatMassTableViewCell {
            let sample = samples[indexPath.row]
            cell.fatMassLabel.text = "\(sample.value) \(sample.unit)"
            cell.bodyCompositionLabel.text = "(\(sample.bodyMass.value) \(sample.bodyMass.unit) at \(sample.bodyFatPercentage.value*100)% bf)"
            return cell
        } else {
            fatalError("Failed to load custom cell type")
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            samples.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

