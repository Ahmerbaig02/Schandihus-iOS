//
//  AddProspectVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 02/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import UITextView_Placeholder
import Alamofire

class AddProspectVC: UIViewController {

    @IBOutlet weak var prospectNameTF: ConstructionTextField!
    @IBOutlet weak var contactNumTF: ConstructionTextField!
    @IBOutlet weak var workAddressTF: ConstructionTextField!
    @IBOutlet weak var homeAddressTF: ConstructionTextField!
    @IBOutlet weak var statusTF: ConstructionTextField!
    @IBOutlet weak var generalDiscountTF: ConstructionTextField!
    @IBOutlet weak var addProspectBtn: UIButton!
    
    var statusArr: [String] = ["IMPORTANT","NORMAL","VIP"]
    var prospect: ProspectData!
    var urlStr: String = Helper.PostProspectURL
    var method: HTTPMethod = .post
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRightView(textField: statusTF)
        setPickerView(textField: statusTF, tag: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let lookup = LookupData.shared {
            self.statusArr = lookup.status!.map({ $0.value!})
        }
        
        if prospect != nil {
            self.setValues()
        } else {
            self.navigationItem.title = "Add Prospect"
            self.addProspectBtn.setTitle("Add Prospect", for: .normal)
        }
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.prospectNameTF, rules: [RequiredRule()])
        validator.registerField(self.contactNumTF, rules: [RequiredRule()])
        validator.registerField(self.workAddressTF, rules: [RequiredRule()])
        validator.registerField(self.homeAddressTF, rules: [RequiredRule()])
        validator.registerField(self.statusTF, rules: [RequiredRule()])
        validator.registerField(self.generalDiscountTF, rules: [RequiredRule()])
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
                self!.postProspectFromManager()
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
        self.prospectNameTF.text = prospect?.prospectName ?? ""
        self.contactNumTF.text = prospect?.contactNumber ?? ""
        self.workAddressTF.text = prospect?.workAddress ?? ""
        self.homeAddressTF.text = prospect?.homeAddress ?? ""
        self.statusTF.text = prospect?.status ?? ""
        self.generalDiscountTF.text = String(prospect?.generalDiscount ?? 0)
        self.navigationItem.title = "Edit Prospect"
        self.addProspectBtn.setTitle("Update Prospect", for: .normal)
        
    }
    
    fileprivate func postProspectFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        if prospect != nil {
            urlStr = "\(Helper.PostProspectURL)/\(prospect!.prospectId ?? 0)"
            method = .put
        }
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: urlStr, method: method, headers: nil, encoding: JSONEncoding.default, parameters: ["prospectName": prospectNameTF.text!.capitalizingFirstLetter(), "contactNumber": contactNumTF.text!, "workAddress": workAddressTF.text!, "homeAddress": homeAddressTF.text!, "status": statusTF.text!, "generalDiscount": generalDiscountTF.text!]) { [weak self] (response: BaseResponse?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Prospect")
                self?.navigationController?.popViewController(animated: true)
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }

    @IBAction func addProspectAction(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddProspectVC")
    }

}

extension AddProspectVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statusArr.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statusArr[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return statusTF.text = statusArr[row]
    }
    
}
