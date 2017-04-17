//
//  DetailViewController.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/1/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: Properties
    var fatSample: FatMassSample? = nil
    
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyWeightLabel: UILabel!
    @IBOutlet weak var bodyFatPercentageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if fatSample != nil {
            bodyWeightLabel.text = "\(fatSample!.bodyMass.value) \(fatSample!.bodyMass.unit)"
            bodyFatPercentageLabel.text = "\(fatSample!.bodyFatPercentage.value*100)%"
            dateLabel.text = formatDate(date: (fatSample!.date))
        } else {
            bodyWeightLabel.text = ""
            bodyFatPercentageLabel.text = ""
            dateLabel.text = ""
        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

