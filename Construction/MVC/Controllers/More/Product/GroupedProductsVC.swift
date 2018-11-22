//
//  ProductsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

protocol ProductDelegate: class {
    func GroupedProducts(controller: GroupedProductsVC, products: [ProductData])
}

class GroupedProductsVC: UIViewController {
    
    @IBOutlet weak var groupedProductsTblView: UITableView!
    
    weak var delegate: ProductDelegate?
    
    var products : [ProductData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var selectedProducts: [ProductData] = []
    var product: ProductData!
    var productsSectionedData:[[ProductData]] = []
    var uniqueInitials: [String] = []
    var isForProductVendor: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.groupedProductsTblView.sectionIndexColor = UIColor.primaryColor
        self.groupedProductsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.groupedProductsTblView.delegate = self
        self.groupedProductsTblView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getProductListFromManager()
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.productsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(products.map({ String($0.name!.first!) })).sorted()
        for initial in uniqueInitials {
            self.productsSectionedData.append(self.products.filter({ String($0.name!.first!) == initial }))
        }
        self.groupedProductsTblView.reloadData()
    }
    
    fileprivate func getProductListFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProductsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProductData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.products = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func postGroupedProductsFromManager(productIds: [[String:Any]]) {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetGroupedProductsURL, method: .post, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId! , "groupedProducts": productIds]) { [weak self] (response: BaseResponse?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if response?.success == true {
                print("Posted Grouped Products")
                self?.navigationController?.popViewController(animated: true)
            } else {
                if productIds.count == 0 {
                    self!.showBanner(title: "Select a product first!", style: .info)
                } else {
                 self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                }
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func showAlertForQuantity(indexPath: IndexPath) {
        let alertVC = UIAlertController(title: "Product Quantity", message: "Enter Quantity for \(self.products[indexPath.row].name ?? "") below", preferredStyle: .alert)
        alertVC.addTextField { (textField) in
            textField.placeholder = "e.g.. 3"
            textField.keyboardType = .numberPad
        }
        alertVC.addAction(UIAlertAction.init(title: "Submit", style: .default, handler: { [weak self] (action) in
            var newProduct = self!.productsSectionedData[indexPath.section][indexPath.row]
            newProduct.quantity = (alertVC.textFields![0].text as NSString?)!.integerValue
            self?.selectedProducts.append(newProduct)
            self?.groupedProductsTblView.reloadData()
        }))
        alertVC.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func addGroupedProducts(_ sender: Any) {
        if delegate != nil {
            delegate?.GroupedProducts(controller: self, products: selectedProducts)
            return
        }
        let productIds = self.selectedProducts.map( { ["groupedProductId": $0.productId!, "quantity": $0.quantity!] })
        postGroupedProductsFromManager(productIds: productIds)
    }
    
    deinit {
        print("deinit GroupedProductsVC")
    }
    
}

extension GroupedProductsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.productsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = groupedProductsTblView.dequeueReusableCell(withIdentifier: Helper.GroupedProductsCellID, for: indexPath)
        cell.textLabel?.text = productsSectionedData[indexPath.section][indexPath.row].name ?? ""
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        cell.detailTextLabel?.textColor = UIColor.darkGray
        cell.detailTextLabel?.attributedText = getAttributedText(Titles: [product.name?.capitalizingFirstLetter() ?? "N/A", "\(product.minimumRetailPrice ?? 0)€ - \(product.maximumRetailPrice ?? 0)€"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 12.0),UIFont.systemFont(ofSize: 12.0)], Colors: [UIColor.primaryColor, UIColor.gray, UIColor.gray], seperator: ["\n","\n",""], Spacing: 3, atIndex: 0)
//        cell.detailTextLabel?.text = "\(String(products[indexPath.row].minimumRetailPrice ?? 0))€ - \(String(products[indexPath.row].maximumRetailPrice ?? 0))€\nCost: \((products[indexPath.row].productCost ?? 0.0).getRounded(uptoPlaces: 2))€\nSale Price: \((self.products[indexPath.row].productSalePrice ?? 0.0).getRounded(uptoPlaces: 2))€"
        cell.tintColor = UIColor.accentColor
        if selectedProducts.contains(where: { $0.productId == self.productsSectionedData[indexPath.section][indexPath.row].productId }) {
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_check_circle_outline_black_18pt")
        } else {
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_radio_button_unchecked_black_18pt")
        }
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.uniqueInitials
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.uniqueInitials[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            hView.contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
            hView.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            hView.textLabel?.textColor = UIColor.primaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.groupedProductsTblView.deselectRow(at: indexPath, animated: true)
        if let index = selectedProducts.index(where: { $0.productId == self.productsSectionedData[indexPath.section][indexPath.row].productId }) {
            selectedProducts.remove(at: index)
        } else {
//            if self.delegate == nil {
//                selectedProducts.append(self.productsSectionedData[indexPath.section][indexPath.row])
//            } else {
//                self.showAlertForQuantity(indexPath: indexPath)
//            }
            self.showAlertForQuantity(indexPath: indexPath)
        }
        self.groupedProductsTblView.reloadData()
    }
    
}
