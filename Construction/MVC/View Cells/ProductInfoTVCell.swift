////
//  ProductInfoTVCell.swift
//  Construction
//
//  Created by CodeX on 27/11/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit

class ProductInfoTVCell: UITableViewCell {

    @IBOutlet var infoLbl: UILabel!
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.titleLbl.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
        self.titleLbl.textColor = UIColor.primaryColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.productImageView.setBorder(width: 1, color: UIColor.lightGray)
    }
    
    deinit {
        print("ProductInfoTVCell deinit")
    }
}
