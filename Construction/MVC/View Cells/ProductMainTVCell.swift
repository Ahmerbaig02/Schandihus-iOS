//
//  ProductMainTVCell.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 05/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class ProductMainTVCell: UITableViewCell {

    @IBOutlet var amountLbl: UILabel!
    @IBOutlet var quantityTextField: UITextField!
    @IBOutlet var imageBGView: UIView!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userInfoLbl: UILabel!
    
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.amountLbl.textColor = UIColor.primaryColor
        self.quantityTextField.placeholder = "Quantity"
        self.amountLbl.isHidden = true
        self.quantityTextField.isHidden = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImgView.getRounded(cornerRaius: userImgView.frame.width/2)
        imageBGView.getRounded(cornerRaius: imageBGView.frame.width/2)
        imageBGView.setBorder(width: 0.5, color: UIColor.primaryColor)
    }
    
}
