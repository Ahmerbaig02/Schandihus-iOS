////
//  AddEstimateProductTVCell.swift
//  Construction
//
//  Created by CodeX on 24/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit

class AddEstimateProductTVCell: UITableViewCell {

    @IBOutlet var nameLbl: UILabel!
    @IBOutlet var infoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.nameLbl.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        self.infoLbl.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        self.nameLbl.textColor = UIColor.black
        self.infoLbl.textColor = UIColor.darkGray
    }
    
}
