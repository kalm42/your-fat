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
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var bodyWeightLabel: UILabel!
    @IBOutlet weak var bodyFatPercentageLabel: UILabel!
    var bwLabelText: String = ""
    var bfLabelText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bodyWeightLabel.text = bwLabelText
        bodyFatPercentageLabel.text = bfLabelText
        dateLabel.text = formatDate(date: Date())
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

