//
//  FatSampleCell.swift
//  Your Fat
//
//  Created by Kyle Melton on 4/16/17.
//  Copyright © 2017 Kyle Melton. All rights reserved.
//

import UIKit

class FatMassTableViewCell: UITableViewCell {
    
    //Outlets
    @IBOutlet weak var fatMassLabel: UILabel!
    @IBOutlet weak var bodyCompositionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}

