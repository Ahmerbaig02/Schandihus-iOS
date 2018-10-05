////
//  NotesTVCell.swift
//  Construction
//
//  Created by CodeX on 04/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit

class NotesTVCell: UITableViewCell {

    @IBOutlet var dateLbl: UILabel!
    @IBOutlet var contentLbl: UILabel!
    @IBOutlet var headerLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    deinit {
        print("NotesTVCell deinit")
    }
}
