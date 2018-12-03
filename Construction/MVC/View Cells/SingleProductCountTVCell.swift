//
//  SingleProductCountTVCell.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 03/12/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class SingleProductCountTVCell: UITableViewCell {

    @IBOutlet var pcsLbl: UILabel!
    @IBOutlet var countLbl: UILabel!
    @IBOutlet var quantityTextField: ConstructionTextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.quantityTextField.textAlignment = .center
        self.quantityTextField.textColor = UIColor.primaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    deinit {
        print("SingleProductCountTVCell deinit")
    }
}
