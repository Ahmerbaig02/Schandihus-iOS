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

    fileprivate func postProductParamsFromManager() {
        let params: [[String: Any]] = [["parameterName": paramNameTF.text!, "parameterValue": Double(paramValueTF.text!) ?? 0, "parameterUnit": paramUnitTF.text!]]
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString:  Helper.PostProductParamsURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId ?? 0, "parameters": params]) { [weak self] (response: BaseResponse?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                self!.showBanner(title: "Parameter added successfully", style: .success)
                print("Posted Product Parameters")
                self!.paramNameTF.text = ""
                self!.paramValueTF.text = ""
                self!.paramUnitTF.text = ""
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func submitAction(_ sender: Any) {
        self.postProductParamsFromManager()
    }
    
    deinit{
        print("deinit AddParamsVC")
    }

}
