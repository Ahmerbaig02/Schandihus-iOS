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

    @IBOutlet var addImageIconView: UIButton!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var userNameTF: ConstructionTextField!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var minRetailPriceTF: ConstructionTextField!
    @IBOutlet weak var maxRetailPriceTF: ConstructionTextField!
    @IBOutlet weak var markupTF: ConstructionTextField!
    @IBOutlet weak var productCostTF: ConstructionTextField!
    @IBOutlet weak var productSalePriceTF: ConstructionTextField!
    
    @IBOutlet weak var updateBtn: UIButton!
    
    var product: ProductData! = ProductData()
    var urlStr: String = Helper.PostProductURL
    var method: HTTPMethod = .post
    var imgURL: URL!
    var productId: Int?
    
    var isGroupedProduct: Bool = false
    var shouldUpdatePhoto: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imgURL = #imageLiteral(resourceName: "baseline_account_circle_black_24pt").getURLFor(filename: "productImage")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if product.productId != nil {
            self.setValues()
            self.isGroupedProduct = product.grouped ?? false
            self.updateBtn.setTitle("Submit", for: .normal)
            self.navigationItem.title = "Edit Product"
            self.userImgView.pin_updateWithProgress = true
            self.userImgView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"), placeholderImage: #imageLiteral(resourceName: "Placeholder Image"))
        } else {
            self.shouldUpdatePhoto = true
            self.updateBtn.setTitle("Add Product", for: .normal)
        }
        self.descriptionTV.placeholder = "Description..."
        print(imgURL)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.userImgView.getRounded(cornerRaius: userImgView.frame.width/2)
        self.addImageIconView.getRounded(cornerRaius: self.addImageIconView.frame.width/2)
        self.addImageIconView.setBorder(width: 1, color: UIColor.accentColor)
        self.userImgView.setBorder(width: 1, color: UIColor.accentColor)
    }
    
    fileprivate lazy var validator: Validator = {
        let validator = Validator()
        validator.registerField(self.userNameTF, rules: [RequiredRule()])
        validator.registerField(self.minRetailPriceTF, rules: [RequiredRule()])
        validator.registerField(self.maxRetailPriceTF, rules: [RequiredRule()])
        validator.registerField(self.markupTF, rules: [RequiredRule()])
        validator.registerField(self.productCostTF, rules: [RequiredRule()])
        validator.registerField(self.productSalePriceTF, rules: [RequiredRule()])
        return validator
    }()
    
    fileprivate func setValues() {
        userNameTF.text = product.name ?? ""
        descriptionTV.text = product.description ?? ""
        minRetailPriceTF.text = String(product.minimumRetailPrice ?? 0)
        maxRetailPriceTF.text = String(product.maximumRetailPrice ?? 0)
        markupTF.text = String(product.markup ?? 0)
        productCostTF.text = String(product.productCost ?? 0)
        productSalePriceTF.text = String(product.productSalePrice ?? 0)
    }
    
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
        product.name = userNameTF.text!.capitalizingFirstLetter()
        product.description = descriptionTV.text ?? ""
        product.minimumRetailPrice = Int(minRetailPriceTF.text!)
        product.maximumRetailPrice = Int(maxRetailPriceTF.text!)
        product.markup = Int(markupTF.text!)
        product.productCost = (productCostTF.text as NSString?)!.doubleValue
        product.productSalePrice = (productSalePriceTF.text as NSString?)!.doubleValue
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddParamsVC {
            destinationVC.product = (sender as! ProductData)
        }
    }
    
    fileprivate func postProductFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        if product.productId != nil {
            urlStr = "\(Helper.PostProductURL)/\(product!.productId ?? 0)"
            method = .put
        }
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: urlStr, method: method, headers: nil, encoding: JSONEncoding.default, parameters: ["name": product.name!, "description": product.description!, "minimumRetailPrice": product.minimumRetailPrice!, "maximumRetailPrice": product.maximumRetailPrice!, "markup": product.markup!, "productCost": product.productCost!, "productSalePrice": product.productSalePrice!, "groupedProducts": [],"grouped": isGroupedProduct, "parameters": []]) { [weak self] (response: BasicResponse<Int>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Product")
                self!.productId = response?.data!
                self!.product.productId = self!.productId
                if self?.shouldUpdatePhoto == true {
                    self?.postProductImageFromManager()
                } else {
                    UIViewController.hideLoader()
                    _ = self?.navigationController?.popViewController(animated: true)
                }
            } else {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func postProductImageFromManager() {
        NetworkManager.uploadFileOnServer(urlString: "\(Helper.PinterBaseURL)\(Helper.PostImageURL)?id=\(productId!)", fileURL: imgURL, filename: "product_\(productId!).jpg", withName: "UploadedImage") { [weak self] (response: BasicResponse<String>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Image")
                print(response?.data ?? "")
                clearImageFromCache(image_url: URL.init(string: "\(Helper.GetProductImageURL)\(self!.product.productId!).jpg")!)
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
                    if let url = modifiedImage.getURLFor(filename: "productImage") {
                        print(url)
                        self?.shouldUpdatePhoto = true
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
        self.view.endEditing(true)
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddProductVC")
    }

}

extension AddProductVC: UITextViewDelegate, UITextFieldDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        getValues()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        getValues()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        getValues()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        getValues()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getValues()
        return true
    }
}
