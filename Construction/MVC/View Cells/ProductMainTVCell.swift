//
//  ProductMainTVCell.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 05/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class ProductMainTVCell: UITableViewCell {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userInfoLbl: UILabel!
    
    override var bounds: CGRect {
        didSet {
            self.layoutIfNeeded()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        userImgView.getRounded(cornerRaius: userImgView.frame.width/2)
    }
    
}
