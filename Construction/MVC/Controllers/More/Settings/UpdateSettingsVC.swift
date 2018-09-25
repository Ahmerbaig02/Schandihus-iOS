//
//  UpdateSettingsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 30/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import UITextView_Placeholder
import SwiftValidator
import Alamofire

class UpdateSettingsVC: UIViewController {

    @IBOutlet weak var companyAddressTF: ConstructionTextField!
    @IBOutlet weak var accountNumTF: ConstructionTextField!
    @IBOutlet weak var bankNameTF: ConstructionTextField!
    @IBOutlet weak var bankCodeTF: ConstructionTextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    var companyData: LookupData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.descriptionTV.placeholder = "Description"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        companyAddressTF.text = companyData.companyInfo?.COMPANY_ADDRESS ?? ""
        accountNumTF.text = companyData.companyInfo?.COMPANY_ACCOUNT_NUMBER ?? ""
        bankNameTF.text = companyData.companyInfo?.COMPANY_BANK_NAME ?? ""
        bankCodeTF.text = companyData.companyInfo?.COMPANY_BANK_BRANCH_CODE ?? ""
        descriptionTV.text = companyData.companyInfo?.COMPANY_INFO ?? ""
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.descriptionTV.setBorder(width: 0.5, color: UIColor.gray)
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.companyAddressTF, rules: [RequiredRule()])
        validator.registerField(self.accountNumTF, rules: [RequiredRule()])
        validator.registerField(self.bankNameTF, rules: [RequiredRule()])
        validator.registerField(self.bankCodeTF, rules: [RequiredRule()])
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
                self!.postCompanyInfoFromManager()
            }
        }
    }
    
    fileprivate func postCompanyInfoFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.PostCompanyInfoURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["companyAddress": companyAddressTF.text!, "companyAccountNumber": accountNumTF.text!, "companyBankName": bankNameTF.text!, "companyBranchCode": bankCodeTF.text!, "companyInfo": descriptionTV.text!]) { [weak self] (response: BasicResponse<ss>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Updated Company Info")
                self!.navigationController?.popViewController(animated: true)
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
            
        }
    }
    
    @IBAction func updateCompanyInfo(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit UpdateSettingsVC")
    }
    
}
