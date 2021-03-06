////
//  AddNotesVC.swift
//  Construction
//
//  Created by CodeX on 04/10/2018
//  Copyright © 2018 Dev_iOS. All rights reserved.
//

import UIKit
import Alamofire
import IQKeyboardManagerSwift
import SwiftValidator

class AddNotesVC: UIViewController {

    @IBOutlet var submitBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTF: ConstructionTextField!
    @IBOutlet weak var contentTV: UITextView!
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.headerTF, rules: [RequiredRule()])
        return validator
    }()
    
    var noteType: Int = -1
    var referenceId: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        self.navigationItem.title = "New Note"
        
        self.headerTF.addTarget(self, action: #selector(self.textChangedListener(_:)), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        IQKeyboardManager.shared.enable = false
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc fileprivate func textChangedListener(_ textField: UITextField) {
        self.validateFieldInput(validator: self.validator, textField: textField)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            self.submitBtnBottomConstraint.constant = (notification.name == NSNotification.Name.UIKeyboardWillHide) ? 20 : keyboardHeight
            UIView.animate(withDuration: 0.4) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    fileprivate func validateInputs() {
        self.validateFields(validator: self.validator) { [weak self] (success) in
            if success {
                for (_, rule) in self!.validator.validations {
                    if let field = rule.field as? ConstructionTextField {
                        field.errorMessage = nil
                    }
                }
                if self!.contentTV.text.isEmpty == true {
                    self!.showBanner(title: "Please enter content", style: .danger)
                    return
                }
                self!.postNotesFromManager()
            }
        }
    }
    
    fileprivate func postNotesFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        let params: [String: Any] = ["referenceId": self.referenceId,
                                     "noteContent": self.contentTV.text!,
                                     "noteType": self.noteType,
                                     "noteHeading": self.headerTF.text!]
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GETNotesURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: params) { [weak self] (res: BasicResponse<Int>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if res?.success == true {
                self!.showBanner(title: "Notes Added", style: .success)
                _ = self!.navigationController?.popViewController(animated: true)
            } else {
                self!.showBanner(title: res?.error ?? "An Error occurred. Please try again.", style: .danger)
                print("Error fetching data")
            }
        }
    }

    @IBAction func submitAction(_ sender: Any) {
        validateInputs()
    }
    
    deinit {
        print("AddNotesVC deinit")
    }
}
