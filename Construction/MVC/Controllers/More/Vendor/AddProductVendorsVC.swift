//
//  VendorForProductVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 03/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire

class AddProductVendorsVC: UIViewController {
    
    @IBOutlet weak var productNameTF: ConstructionTextField!
    @IBOutlet weak var vendorNameTF: ConstructionTextField!
    @IBOutlet weak var priceTF: ConstructionTextField!
    
    var product: ProductData = ProductData()
    var vendor: VendorData = VendorData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.productNameTF.text = product.name ?? ""
        self.vendorNameTF.text = vendor.name ?? ""
        self.productNameTF.isUserInteractionEnabled = false
        self.vendorNameTF.isUserInteractionEnabled = false
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.productNameTF, rules: [RequiredRule()])
        validator.registerField(self.vendorNameTF, rules: [RequiredRule()])
        validator.registerField(self.priceTF, rules: [RequiredRule()])
        return validator
    }()
    
    fileprivate func validateInputs() {
        self.validateFields(validator: self.validator) { [weak self] (success) in
            if success {
                for (_, rule) in self!.validator.validations {
                    if let field = rule.field as? ConstructionTextField {
                        field.errorMessage = nil
                    }
                }
                self!.postProductVendorFromManager()
            }
        }
    }
    
    fileprivate func postProductVendorFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.PostVendorProductURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId ?? 0, "vendorId": vendor.vendorId ?? 0, "vendorPrice": Int(priceTF.text!)!]) { [weak self] (response: BasicResponse<ss>?, error) in
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                self?.navigationController?.goBackViewControllers(n: 2)
            } else {
                print("Error fetching data")
            }
            
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddProductVendorsVC")
    }
    
}
