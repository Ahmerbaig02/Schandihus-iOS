//
//  AddProductVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 30/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import YPImagePicker
import UITextView_Placeholder
import SwiftValidator
import Alamofire

class AddProductVC: UIViewController {

    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameTF: ConstructionTextField!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var minRetailPriceTF: ConstructionTextField!
    @IBOutlet weak var maxRetailPriceTF: ConstructionTextField!
    @IBOutlet weak var markupTF: ConstructionTextField!
    
    var product: ProductData! = ProductData()
    var urlStr: String = Helper.PostProductURL
    var method: HTTPMethod = .post
    var imgURL: URL!
    var productId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.descriptionTV.placeholder = "Description..."
        self.imgURL = #imageLiteral(resourceName: "baseline_account_circle_black_24pt").getURLFor(filename: "productImage.jpg")
        print(imgURL)
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        userImgView.getRounded(cornerRaius: userImgView.frame.width/2)
        self.userImgView.layer.borderColor = UIColor.accentColor.cgColor
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.userNameTF, rules: [RequiredRule()])
        validator.registerField(self.minRetailPriceTF, rules: [RequiredRule()])
        validator.registerField(self.maxRetailPriceTF, rules: [RequiredRule()])
        validator.registerField(self.markupTF, rules: [RequiredRule()])
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
                self!.getValues()
                self!.postProductFromManager()
            }
        }
    }
    
    fileprivate func getValues() {
        product.name = userNameTF.text!
        product.description = descriptionTV.text ?? ""
        product.minimumRetailPrice = Int(minRetailPriceTF.text!)
        product.maximumRetailPrice = Int(maxRetailPriceTF.text!)
        product.markup = Int(markupTF.text!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddParamsVC {
            destinationVC.product = (sender as! ProductData)
        }
    }
    
    fileprivate func postProductFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        if product == nil {
            urlStr = "\(Helper.PostProductURL)/\(product!.productId ?? 0)"
            method = .put
        }
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: urlStr, method: method, headers: nil, encoding: JSONEncoding.default, parameters: ["name": product.name!, "description": product.description!, "minimumRetailPrice": product.minimumRetailPrice!, "maximumRetailPrice": product.maximumRetailPrice!, "markup": product.markup!, "groupedProducts": [], "parameters": []]) { [weak self] (response: BasicResponse<Int>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Product")
                self?.productId = response?.data ?? 0
                self?.postProductImageFromManager()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func postProductImageFromManager() {
        NetworkManager.uploadFileOnServer(urlString: "\(Helper.PinterBaseURL)\(Helper.PostImageURL)?id=\(productId!)", fileURL: imgURL, filename: "product_\(productId!).jpg", withName: "UploadedImage") { [weak self] (response: BasicResponse<String>?, error) in
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Image")
                print(response?.data ?? "")
                self?.navigationController?.popViewController(animated: true)
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func addUserImage(_ sender: Any) {
        print("pic upload")
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.showsCrop = .rectangle(ratio: 320.0/320.0)
        config.onlySquareImagesFromCamera = true
        config.targetImageSize = .original
        config.usesFrontCamera = true
        config.showsFilters = false
        config.shouldSaveNewPicturesToAlbum = false
        
        let imgPicker = YPImagePicker.init(configuration: config)
        imgPicker.didFinishPicking { [unowned imgPicker, weak self] items, _ in
            if let photo = items.singlePhoto {
                if let modifiedImage = photo.modifiedImage {
                    if let url = modifiedImage.getURLFor(filename: "productImage.jpg") {
                        print(url)
                        self?.imgURL = url
                        self?.userImgView.image = modifiedImage
                    } else {
                        print("error making url for file")
                    }
                }
            }
            imgPicker.dismiss(animated: true, completion: nil)
        }
        present(imgPicker, animated: true, completion: nil)
    }
    
    @IBAction func submit(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddProductVC")
    }

}
