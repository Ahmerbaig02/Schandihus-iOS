////
//
//  Created by CodeX on 23/02/2018.
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ConstructionTextField: SkyFloatingLabelTextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.textColor = UIColor.primaryColor
        self.selectedTitleColor = UIColor.primaryColor
        self.titleFont = UIFont.systemFont(ofSize: 9)
        self.lineColor = UIColor.gray
        self.lineHeight = 0.5
        self.selectedLineColor = UIColor.primaryColor
    }
    
//    override func titleLabelRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
//        return CGRect(origin: CGPoint(x: bounds.origin.x + 10, y: bounds.origin.y - titleHeight() - 4), size: bounds.size)
//    }
//    
//    override func textRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect(origin: CGPoint(x: bounds.origin.x + 10, y: 2), size: bounds.size)
//    }
//    
//    override func editingRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect(origin: CGPoint(x: bounds.origin.x + 10, y: 2), size: bounds.size)
//    }
//    
//    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
//        return CGRect(origin: CGPoint(x: bounds.origin.x + 10, y: 2), size: bounds.size)
//    }
//    
//    override func lineViewRectForBounds(_ bounds: CGRect, editing: Bool) -> CGRect {
//        return .zero
//    }
    
    deinit {
        print("ConstructionTextField deinit")
    }
}
