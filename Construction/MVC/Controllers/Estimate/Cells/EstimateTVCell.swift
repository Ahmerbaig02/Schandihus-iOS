////
//  EstimateTVCell.swift
//  Construction
//
//  Created by CodeX on 11/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit

protocol EstimateTVCellDelegate: class {
    func showQuickInfo(cell: EstimateTVCell)
}

class EstimateTVCell: UITableViewCell {
    
    var viewQuickInfoLongPressGetsure: UILongPressGestureRecognizer!
    
    weak var delegate: EstimateTVCellDelegate?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        gesture.minimumPressDuration = 0.5
        self.viewQuickInfoLongPressGetsure = gesture
        self.addGestureRecognizer(gesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    @objc fileprivate func longPressAction(_ gesture: UILongPressGestureRecognizer) {
        delegate?.showQuickInfo(cell: self)
    }
    
    deinit {
        print("EstimateTVCell deinit")
    }
}
