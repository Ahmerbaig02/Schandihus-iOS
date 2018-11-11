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
    
    @IBOutlet var expectedPriceLbl: UILabel!
    @IBOutlet weak var productNameTF: ConstructionTextField!
    @IBOutlet weak var vendorNameTF: ConstructionTextField!
    @IBOutlet weak var priceTF: ConstructionTextField!
    @IBOutlet weak var expectedTimeTF: ConstructionTextField!
    @IBOutlet weak var unitsTF: ConstructionTextField!
    
    var product: ProductData = ProductData()
    var vendor: VendorData = VendorData()
    
    var times: [String] = ["10 min", "15 min", "20 min", "25 min", "30 min", "35 min", "40 min", "45 min", "50 min", "55 min", "60 min", "2 hours", "3 hours", "4 hours"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let price = product.suggestedVendorPrice, price > 0.0 {
            self.expectedPriceLbl.text = "Suggested Price by Vendor: \(price.getRounded(uptoPlaces: 2))€"
            self.expectedPriceLbl.isHidden = false
        } else {
            self.expectedPriceLbl.isHidden = true
        }
        
        self.productNameTF.text = product.name ?? ""
        self.vendorNameTF.text = vendor.name ?? ""
        self.unitsTF.text = "1"
        self.productNameTF.isUserInteractionEnabled = false
        self.vendorNameTF.isUserInteractionEnabled = false
        
        let timesPicker = UIPickerView()
        timesPicker.delegate = self
        timesPicker.dataSource = self
        self.expectedTimeTF.inputView = timesPicker
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.productNameTF, rules: [RequiredRule()])
        validator.registerField(self.vendorNameTF, rules: [RequiredRule()])
        validator.registerField(self.priceTF, rules: [RequiredRule()])
        validator.registerField(self.unitsTF, rules: [RequiredRule()])
        validator.registerField(self.expectedTimeTF, rules: [RequiredRule()])
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
        UIViewController.showLoader(text: "Please Wait...")
        let pramas: [String:Any] = ["vendorUnits": Int(self.unitsTF.text!)!,
                                    "expectedDeliveryTime": self.expectedTimeTF.text!,
                                    "productId": product.productId ?? 0,
                                    "vendorId": vendor.vendorId ?? 0,
                                    "vendorPrice": Int(priceTF.text!)!]
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.PostVendorProductURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: pramas) { [weak self] (response: BasicResponse<BaseResponse>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                self?.navigationController?.goBackViewControllers(n: 2)
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
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

extension AddProductVendorsVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return times.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return times[row]
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.expectedTimeTF.text = self.times[row]
    }
}
