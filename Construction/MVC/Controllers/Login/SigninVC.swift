//
//  ViewController.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire

class SigninVC: UIViewController {

    @IBOutlet weak var appIconImgView: UIImageView!
    @IBOutlet weak var emailTF: ConstructionTextField!
    @IBOutlet weak var passwordTF: ConstructionTextField!
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.emailTF, rules: [RequiredRule(), RequiredRule(message: "must be a valid username")])
        validator.registerField(self.passwordTF, rules: [RequiredRule(), PasswordRule(regex: ".{6,}$", message: "Password must be 6 characters")])
        return validator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTF.delegate = self
        self.passwordTF.delegate = self
        
        self.emailTF.keyboardType = .alphabet
        self.emailTF.addTarget(self, action: #selector(self.textChangedListener(_:)), for: .editingChanged)
        self.passwordTF.addTarget(self, action: #selector(self.textChangedListener(_:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.emailTF.text = ""
        self.passwordTF.text = ""
        if UserDefaults.standard.bool(forKey: Helper.isLoggedInDefaultID) == true {
            verifyCredentialsFromManager()
        }
    }
    
    fileprivate func verifyCredentialsFromManager() {
        self.performSegue(withIdentifier: Helper.loginSegueID, sender: nil)
    }
    
    fileprivate func validateInputs() {
        self.validateFields(validator: self.validator) { [weak self] (success) in
            if success {
                for (_, rule) in self!.validator.validations {
                    if let field = rule.field as? ConstructionTextField {
                        field.errorMessage = nil
                    }
                }
                self!.postUserFromManager()
            }
        }
    }
    
    fileprivate func postUserFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.PostUsersURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["userName": emailTF.text!, "password": passwordTF.text!]) { [weak self] (user: BasicResponse<UserData>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if user?.success == true {
                print(user ?? "")
                let data = encodeObject(param: user?.data!)
                UserDefaults.standard.set(data, forKey: Helper.UserProfileDefaultsID)
                UserDefaults.standard.set(true, forKey: Helper.isLoggedInDefaultID)
                self?.verifyCredentialsFromManager()
            } else {
                self!.showBanner(title: user?.error ?? "An Error occurred. Please try again.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @objc fileprivate func textChangedListener(_ textField: UITextField) {
        self.validateFieldInput(validator: self.validator, textField: textField)
    }
    
    @IBAction func loginAction(_ sender: Any) {
        validateInputs()
    }
    
    deinit {
        print("deinit LoginVC")
    }

}

extension SigninVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            validateInputs()
        }
        return true
    }
}

