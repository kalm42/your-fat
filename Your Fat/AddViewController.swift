//
//  AddViewController.swift
//  Your Fat
//
//  Created by Kyle Melton on 3/11/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit

class AddViewController: UIViewController {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var bodyMassUnit: UISegmentedControl!
    @IBOutlet weak var bodyMassTextField: UITextField!
    @IBOutlet weak var bodyFatPercentageTextField: UITextField!
    var selectedIndex = 0
    var date = Date()
    var uom: UnitOfMeasurement {
        get {
            switch bodyMassUnit.selectedSegmentIndex {
            case 0:
                return .kg
            case 1:
                return .lb
            default:
                return .lb
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        datePickerView.isHidden = true
        dateLabel.text = formatDate(date: date)
        bodyMassUnit.selectedSegmentIndex = selectedIndex
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func datePickerViewState(_ sender: UITapGestureRecognizer) {
        datePickerView.isHidden = !datePickerView.isHidden
    }
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        date = datePicker.date
        dateLabel.text = formatDate(date: datePicker.date)
        
    }

}
