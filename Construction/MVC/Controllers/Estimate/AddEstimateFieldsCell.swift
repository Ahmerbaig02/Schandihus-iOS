//
//  AddEstimateFieldsCell.swift
//  Construction
//
//  Created by Mahnoor Fatima on 04/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class AddEstimateFieldsCell: UITableViewCell {

    @IBOutlet weak var estimateNameTF: ConstructionTextField!
    @IBOutlet weak var estimateDateTF: ConstructionTextField!
    @IBOutlet weak var closingDateTF: ConstructionTextField!
    @IBOutlet weak var priceGuaranteeDateTF: ConstructionTextField!
    
    deinit {
        print("deinit AddEstimateFieldsCell")
    }
}
