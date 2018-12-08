//
//  ProductDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import PINRemoteImage

class ProductDetailsVC: UIViewController {
    
    @IBOutlet weak var productDetailsTblView: UITableView!
    @IBOutlet weak var vendorsBtn: UIButton!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    var product: ProductData! = ProductData()
    var grouped: [ProductData]! = []
    var params: [ParamsData]! = []
    var paramTitles: [String] = []
    var paramDescripts: [String] = []
    var groupedProducts: [String] = []
    
    fileprivate lazy var addParameterBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addProductParametersAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    fileprivate lazy var addGroupProductBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addGroupedProductsAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    fileprivate var selectedGroupedProductIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productDetailsTblView.delegate = self
        self.productDetailsTblView.dataSource = self
        self.configureCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getProductDetailsFromManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? VendorsVC {
            destinationVC.isForVendorProduct = true
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? ProductVendorsVC {
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? AddProductVC {
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? AddParamsVC {
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? GroupedProductsVC {
            destinationVC.product = product!
            destinationVC.selectedProducts = grouped ?? []
        }
    }
    
    @objc fileprivate func addProductParametersAction(btn: UIButton) {
        self.performSegue(withIdentifier: Helper.AddProductParametersSegueID, sender: nil)
    }
    
    @objc fileprivate func addGroupedProductsAction(btn: UIButton) {
        self.performSegue(withIdentifier: Helper.AddGroupedProductsSegueID, sender: nil)
    }
    
    fileprivate func setValues() {
        paramTitles.removeAll()
        paramDescripts.removeAll()
        groupedProducts.removeAll()
        if params.count != 0 {
            let count = params.count-1
            for index in 0...count {
                let param = params[index]
                paramTitles.append(param.parameterName!)
                paramDescripts.append("\(param.parameterValue!.getRounded(uptoPlaces: 2)) \(param.parameterUnit!)")
            }
        } else {
            paramTitles.append("No Product Parameters")
            paramDescripts.append("")
        }
        if grouped.count != 0 {
            let count = grouped.count-1
            for index in 0...count {
                let product = grouped[index]
                groupedProducts.append(product.name!)
            }
        } else {
            groupedProducts.append("No Grouped Products")
        }
        productDetailsTblView.reloadData()
    }
    
    func configureCell() {
        self.productDetailsTblView.register(UINib(nibName: "ProductMainTVCell", bundle: nil), forCellReuseIdentifier: Helper.ProductsCellID)
        self.productDetailsTblView.register(RightDetailedTableViewCell.self, forCellReuseIdentifier: "RightDetailedTableViewCell")
        let cellNib = UINib.init(nibName: "ProductInfoTVCell", bundle: nil)
        self.productDetailsTblView.register(UINib(nibName: "SingleProductCountTVCell", bundle: nil), forCellReuseIdentifier: "SingleProductCountTVCell")
        productDetailsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Parameter", message: "Are you sure you want to delete this parameter?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
            self?.deleteParametersFromManager(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func getProductDetailsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductDetailsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<ProductData>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.product = data?.data ?? nil
                self?.getProductParamsFromManager()
            } else {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getProductParamsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductParamsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ParamsData]>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.params = list?.data ?? []
                self?.product.ProductParameter = list?.data ?? []
                if self?.product.grouped == true {
                    self?.getGroupedProductsFromManager()
                } else {
                    UIViewController.hideLoader()
                    self?.setValues()
                }
            } else {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getGroupedProductsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductGroupedProductsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProductData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.grouped = list?.data ?? []
                self?.setValues()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func deleteParametersFromManager(indexPath: IndexPath) {
        UIViewController.showLoader(text: "Please Wait...")
        let param = params[indexPath.row]
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProductParamsURL, method: .delete, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId ?? 0, "parameterName": param.parameterName ?? ""]) { [weak self] (list: BaseResponse?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print("Error")
                self?.params.remove(at: indexPath.row)
                self?.paramTitles.remove(at: indexPath.row)
                self?.paramDescripts.remove(at: indexPath.row)
                self?.productDetailsTblView.deleteRows(at: [indexPath], with: .fade)
            } else {
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func postGroupedProductsFromManager(productIds: [[String:Any]]) {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProductGroupedProductsURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId! , "groupedProducts": productIds]) { [weak self] (response: BaseResponse?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Grouped Products")
                self?.getGroupedProductsFromManager()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func postProductFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        let params: [String: Any] = ["name": product.name!, "description": product.description!, "minimumRetailPrice": product.minimumRetailPrice!, "maximumRetailPrice": product.maximumRetailPrice!, "markup": product.markup!, "productCost": product.productCost!, "productSalePrice": product.productSalePrice!, "groupedProducts": [],"grouped": product.grouped ?? false, "parameters": [], "units": product.units ?? 1]
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.PostProductURL)/\(product.productId ?? 0)", method: .put, headers: nil, encoding: JSONEncoding.default, parameters: params) { [weak self] (response: BasicResponse<Int>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Product")
                self?.getProductDetailsFromManager()
            } else {
                self?.getProductDetailsFromManager()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func showProductVendorsAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.ProductVendorsSegueID, sender: nil)
    }
    
    @IBAction func addProductVendorsAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.ShowVendorsSegueID, sender: nil)
    }
    
    @IBAction func showNotesAction(_ sender: Any) {
        let VC = storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
        VC.noteType = 1
        VC.referenceId = self.product.productId!
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    @IBAction func editProductAction(_ sender: Any) {
        self.performSegue(withIdentifier: Helper.EditProductSegueID, sender: nil)
    }
    
    deinit {
        print("deinit ProductDetailsVC")
    }
    
}

extension ProductDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.product.grouped == true {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if self.product.grouped == true {
                return 2
            }
            return 3
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return paramTitles.count
        } else {
            return groupedProducts.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else if section == 1 {
            return "Description"
        } else if section == 2 {
            return "Parameters"
        } else {
            return "Add Individual Products"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! ProductInfoTVCell
                cell.backgroundColor = UIColor.white
                cell.productImageView.pin_updateWithProgress = true
                cell.productImageView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"), placeholderImage: #imageLiteral(resourceName: "Placeholder Image"))
                
                cell.infoLbl.attributedText = getAttributedText(Titles: [product.name ?? "N/A", "Minimum Retail Price: \(product.minimumRetailPrice ?? 0)€", "Maximum Retail Price: \(product.maximumRetailPrice ?? 0)€ ", "Cost: \((product.productCost ?? 0.0).getRounded(uptoPlaces: 2))€", "Sale Price: \((product.productSalePrice ?? 0.0).getRounded(uptoPlaces: 2))€"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 12.0),UIFont.systemFont(ofSize: 12.0), UIFont.systemFont(ofSize: 12.0), UIFont.systemFont(ofSize: 12.0)], Colors: [UIColor.primaryColor, UIColor.darkGray, UIColor.darkGray, UIColor.darkGray, UIColor.darkGray], seperator: ["\n","\n","\n","\n",""], Spacing: 3, atIndex: 0)
                return cell
            } else if indexPath.row == 2 {
                let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: "SingleProductCountTVCell", for: indexPath) as! SingleProductCountTVCell
                cell.backgroundColor = UIColor.white
                cell.quantityTextField.text = "\(product.units ?? 1)"
                return cell
            }
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textColor = UIColor.primaryColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = "Expected Delivery Time"
            cell.detailTextLabel?.text = product.expectedDeliveryTime ?? "Not Available"
            return cell
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
                cell.textLabel?.textColor = UIColor.primaryColor
                cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
                cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
                cell.textLabel?.text = "Suggested Price by Vendor"
                cell.detailTextLabel?.text = product.suggestedVendorPrice?.getRounded(uptoPlaces: 2) ?? "Not Available"
                cell.backgroundColor = UIColor.white
                return cell
            }
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.backgroundColor = UIColor.white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.textColor = (product.description == nil) ? UIColor.gray : UIColor.black
            cell.textLabel?.text = product.description ?? "No Description Added"
            return cell
        } else if indexPath.section == 2 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            if self.params.count == 0 {
                cell.textLabel?.textColor = UIColor.gray
            } else {
                cell.textLabel?.textColor = UIColor.primaryColor
            }
            cell.backgroundColor = UIColor.white
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = paramTitles[indexPath.row]
            cell.detailTextLabel?.text = paramDescripts[indexPath.row]
            return cell
            
        } else {
            if indexPath.row == self.grouped.count {
                let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: "RightDetailedTableViewCell", for: indexPath) as! RightDetailedTableViewCell
                cell.backgroundColor = UIColor.black.withAlphaComponent(0.8)
                cell.titleLbl.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.semibold)
                cell.titleLbl.text = "Cost"
                cell.titleLbl.textColor = UIColor.primaryColor
                
                let cost = self.grouped.reduce(0) { (res, product) -> Int in
                    return res + ((product.quantity ?? 1) * (product.minimumRetailPrice ?? 0))
                }
                cell.infoLbl.font = UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.semibold)
                cell.infoLbl.text = "Not Available"//"\(cost)€"
                cell.infoLbl.textColor = UIColor.primaryColor
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: Helper.ProductsCellID, for: indexPath) as! ProductMainTVCell
            cell.backgroundColor = UIColor.white
            if self.grouped.count == 0 {
                let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
                cell.textLabel?.text = groupedProducts[indexPath.row]
                cell.textLabel?.textColor = UIColor.gray
                return cell
            }
            let product = self.grouped[indexPath.row]
            cell.userInfoLbl.numberOfLines = 0
            cell.backgroundColor = UIColor.white
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [product.name ?? "N/A", "\(product.minimumRetailPrice ?? 0)€ - \(product.maximumRetailPrice ?? 0)€"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 12.0),UIFont.systemFont(ofSize: 12.0), UIFont.systemFont(ofSize: 12.0),UIFont.systemFont(ofSize: 12.0)], Colors: [UIColor.primaryColor, UIColor.gray, UIColor.gray, UIColor.gray], seperator: ["\n","\n","",""], Spacing: 3, atIndex: 0)
            cell.userImgView.pin_updateWithProgress = true
            cell.userImgView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"), placeholderImage: #imageLiteral(resourceName: "Placeholder Image"))
            
            cell.amountLbl.text = "\((product.minimumRetailPrice ?? 0) * (product.quantity ?? 0))€"
            cell.amountLbl.isHidden = false
            
            cell.quantityTextField.delegate = self
            cell.quantityTextField.tag = indexPath.row
            cell.quantityTextField.text = "\(product.quantity ?? 0)"
            cell.quantityTextField.isHidden = false
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            if section == 2 || section == 3 {
                let addBtn = (section == 2) ? addParameterBtn : addGroupProductBtn
                if !hView.subviews.contains(addBtn) {
                    hView.addSubview(addBtn)
                    addBtn.anchor(hView.topAnchor, left: nil, bottom: hView.bottomAnchor, right: hView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
                } else {
//                    addBtn.removeFromSuperview()
                }
            }
            hView.contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
            hView.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            hView.textLabel?.textColor = UIColor.primaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.productDetailsTblView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            controller.product = self.grouped[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteAlert(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        }
        return false
    }
    
    
}


extension ProductDetailsVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.selectedGroupedProductIndex = textField.tag
    }
    
    fileprivate func updateGroupedProductQuantity(_ textField: UITextField) {
        self.grouped[selectedGroupedProductIndex!].quantity = (textField.text as NSString?)?.integerValue ?? 1
        self.selectedGroupedProductIndex = nil
        let productIds = self.grouped.map( { ["groupedProductId": $0.productId!, "quantity": $0.quantity ?? 1] })
        self.postGroupedProductsFromManager(productIds: productIds)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if self.product.grouped == true {
            updateGroupedProductQuantity(textField)
        } else {
            self.product.units = (textField.text as NSString?)!.integerValue
            self.postProductFromManager()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}
