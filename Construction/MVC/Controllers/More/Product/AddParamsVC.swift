//
//  AddParamsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 30/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import SwiftValidator
import Alamofire

class AddParamsVC: UIViewController {

    @IBOutlet weak var paramNameTF: ConstructionTextField!
    @IBOutlet weak var paramValueTF: ConstructionTextField!
    @IBOutlet weak var paramUnitTF: ConstructionTextField!
    @IBOutlet weak var submitBtn: UIButton!
    
    var product: ProductData! = ProductData()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    
    
    @IBAction func submitAction(_ sender: Any) {
        
    }
    
    deinit{
        print("deinit AddParamsVC")
    }

}
