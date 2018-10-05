//
//  AddVendorVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 30/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire

class AddVendorVC: UIViewController {

    @IBOutlet weak var nameTF: ConstructionTextField!
    @IBOutlet weak var addressTF: ConstructionTextField!
    @IBOutlet weak var regNumTF: ConstructionTextField!
    @IBOutlet weak var VATNumTF: ConstructionTextField!
    @IBOutlet weak var bankNameTF: ConstructionTextField!
    @IBOutlet weak var bankCodeTF: ConstructionTextField!
    @IBOutlet weak var accountNumTF: ConstructionTextField!
    @IBOutlet weak var statusTF: ConstructionTextField!
    @IBOutlet weak var priorityTF: ConstructionTextField!
    @IBOutlet weak var updateBtn: UIButton!
    
    var statusArr: [String] = ["IMPORTANT","NORMAL","VIP"]
    var priorityArr: [String] = ["LOW","MEDIUM","HIGH"]
    var vendor: VendorData?
    var urlStr: String = Helper.PostVendorURL
    var method: HTTPMethod = .post
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRightView(textField: statusTF)
        self.setRightView(textField: priorityTF)
        setPickerView(textField: statusTF, tag: 1)
        setPickerView(textField: priorityTF, tag: 2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lookup = LookupData.shared {
            self.statusArr = lookup.status!.map({ $0.value!})
            self.priorityArr = lookup.priority!.map({ $0.value!})
        }
        
        if vendor != nil {
            self.setValues()
        } else {
            self.updateBtn.setTitle("Add Vendor", for: .normal)
        }
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.nameTF, rules: [RequiredRule()])
        validator.registerField(self.addressTF, rules: [RequiredRule()])
        validator.registerField(self.regNumTF, rules: [RequiredRule()])
        validator.registerField(self.VATNumTF, rules: [RequiredRule()])
        validator.registerField(self.bankNameTF, rules: [RequiredRule()])
        validator.registerField(self.bankCodeTF, rules: [RequiredRule()])
        validator.registerField(self.accountNumTF, rules: [RequiredRule()])
        validator.registerField(self.statusTF, rules: [RequiredRule()])
        validator.registerField(self.priorityTF, rules: [RequiredRule()])
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
                self!.postVendorFromManager()
            }
        }
    }
    
    fileprivate func setPickerView(textField: UITextField, tag: Int) {
        let picker = UIPickerView()
        picker.delegate =  self
        picker.dataSource = self
        textField.inputView = picker
        picker.tag = tag
    }
    
    fileprivate func setRightView(textField: UITextField) {
        if textField.rightView == nil  {
            let rightView = UIImageView(image: #imageLiteral(resourceName: "ic_keyboard_arrow_down"))
            rightView.tintColor = UIColor.lightGray
            rightView.contentMode = .center
            let HW = getCellHeaderSize(Width: self.view.frame.width, aspectRatio: 290/50, padding: 20).height - 10
            let origin = CGPoint(x: textField.frame.width - textField.frame.height, y: 0)
            rightView.frame = CGRect(origin: origin, size: CGSize(width: HW, height: HW))
            textField.rightView = rightView
            textField.rightViewMode = .always
        }
    }
    
    fileprivate func setValues() {
        self.nameTF.text = vendor?.name ?? ""
        self.addressTF.text = vendor?.address ?? ""
        self.regNumTF.text = vendor?.registrationNumber ?? ""
        self.VATNumTF.text = vendor?.vatNumber ?? ""
        self.accountNumTF.text = vendor?.bankAccountNumber ?? ""
        self.bankNameTF.text = vendor?.bankName ?? ""
        self.bankCodeTF.text = vendor?.bankCode ?? ""
        self.statusTF.text = vendor?.status ?? ""
        self.priorityTF.text = vendor?.priority ?? ""
        self.navigationItem.title = "Edit Vendor"
        self.updateBtn.setTitle("Update Vendor", for: .normal)
        
    }
    
    fileprivate func postVendorFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        if vendor != nil {
            urlStr = "\(Helper.PostVendorURL)/\(vendor!.vendorId ?? 0)"
            method = .put
        }
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: urlStr, method: method, headers: nil, encoding: JSONEncoding.default, parameters: ["name": nameTF.text!, "address": addressTF.text!, "registrationNumber": regNumTF.text!, "vatNumber": VATNumTF.text!, "bankName": bankNameTF.text!, "bankCode": bankCodeTF.text!, "bankAccountNumber": accountNumTF.text!, "status": statusTF.text!, "priority": priorityTF.text!]) { [weak self] (response: BasicResponse<BaseResponse>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Vendor")
                if self?.vendor != nil {
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.navigationController?.goBackViewControllers(n: 2)
                    }
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func addVendor(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddVendorVC")
    }
    
}

extension AddVendorVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return statusArr.count
        } else if pickerView.tag == 2 {
            return priorityArr.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return statusArr[row]
        } else if pickerView.tag == 2 {
            return priorityArr[row]
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            return statusTF.text = statusArr[row]
        } else if pickerView.tag == 2 {
            return priorityTF.text = priorityArr[row]
        }
    }
    
}


