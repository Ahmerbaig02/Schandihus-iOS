////
//  RightDetailedTableViewCell.swift
//  Construction
//
//  Created by CodeX on 01/12/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit

class RightDetailedTableViewCell: UITableViewCell {

    var stackView: UIStackView!
    var titleLbl: UILabel!
    var infoLbl: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.titleLbl = UILabel()
        self.infoLbl = UILabel()
        
        self.stackView = UIStackView(arrangedSubviews: [titleLbl, infoLbl])
        
        self.addSubview(stackView)
        
        self.infoLbl.textAlignment = .right
        self.titleLbl.textAlignment = .left
        
        self.stackView.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 8, leftConstant: 8, bottomConstant: 8, rightConstant: 8, widthConstant: 0, heightConstant: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
