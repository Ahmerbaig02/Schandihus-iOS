//
//  ProductsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class ProductsVC: UIViewController {

    
    @IBOutlet weak var productsTblView: UITableView!
    
    var products : [ProductData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    
    var groupedProducts : [GroupedProductData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetterForGroupedProducts()
        }
    }
    var productsSectionedData:[[ProductData]] = []
    var uniqueInitials: [String] = []
    var isForProductVendor: Bool = false
    var vendor: VendorData = VendorData()
    
    fileprivate var isGroupedProductsEnabled: Bool = false
    
    var searchedProducts: [ProductData] = []
    fileprivate var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSearchController()
        
        self.productsTblView.sectionIndexColor = UIColor.primaryColor
        self.productsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.productsTblView.delegate = self
        self.productsTblView.dataSource = self
        
        self.productsTblView.register(UINib(nibName: "ProductMainTVCell", bundle: nil), forCellReuseIdentifier: Helper.ProductsCellID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.isActive = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isGroupedProductsEnabled {
            self.getGroupedProductListFromManager()
        } else {
            getProductListFromManager()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ProductDetailsVC {
            let product = sender as! ProductData
            destinationVC.product = product
        }
        if let destinationVC = segue.destination as? AddProductVendorsVC {
            let product = sender as! ProductData
            destinationVC.vendor = vendor
            destinationVC.product = product
        }
        if let destinationVC = segue.destination as? AddProductVC {
            let grouped = sender as? Bool ?? false
            destinationVC.isGroupedProduct = grouped
        }
    }
    
    fileprivate func setupSearchController() {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.tintColor = UIColor.black
        controller.dimsBackgroundDuringPresentation = false
        controller.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = controller
        navigationItem.hidesSearchBarWhenScrolling = false
        controller.searchBar.sizeToFit()
        
        self.searchController = controller
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.productsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(products.map({ String($0.name!.capitalized.first!) })).sorted()
        for initial in uniqueInitials {
            self.productsSectionedData.append(self.products.filter({ String($0.name!.capitalized.first!) == initial }))
        }
        self.productsTblView.reloadData()
    }
    
    fileprivate func makeSectionIndicesOnFirstLetterForGroupedProducts() {
        self.productsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = []
        for groupedProduct in groupedProducts {
            self.productsSectionedData.append(groupedProduct.products ?? [])
        }
        self.productsTblView.reloadData()
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
                self?.isGroupedProductsEnabled = false
                print(list?.data ?? "Error fetching data")
                self?.products = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getGroupedProductListFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetGroupedProductsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[GroupedProductData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                self?.isGroupedProductsEnabled = true
                print(list?.data ?? "Error fetching data")
                self?.groupedProducts = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func showAddProductTypeAlert() {
        let sheet = UIAlertController(title: "Add Product", message: "Select Product type from below", preferredStyle: UIAlertControllerStyle.actionSheet)
        sheet.addAction(UIAlertAction(title: "Single Product", style: .default, handler: { [weak self] (action) in
            guard let self = self else {return}
            self.performSegue(withIdentifier: Helper.AddProductSegueID, sender: true)
        }))
        sheet.addAction(UIAlertAction(title: "Grouped Product", style: .default, handler: { [weak self] (action) in
            guard let self = self else {return}
            self.performSegue(withIdentifier: Helper.AddProductSegueID, sender: true)
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func addProduct(_ sender: Any) {
        self.showAddProductTypeAlert()
    }
    
    @IBAction func switchToGroupedAction(_ sender: Any) {
        if self.isGroupedProductsEnabled {
            UIViewController.showLoader(text: "Switching to Single Products")
            self.getProductListFromManager()
        } else {
            UIViewController.showLoader(text: "Switching to Grouped Products")
            self.getGroupedProductListFromManager()
        }
    }
    
    deinit {
        print("deinit ProductsVC")
    }
    

}

extension ProductsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.isActive == true {
            return 1
        }
        return self.productsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive == true {
            return self.searchedProducts.count
        }
        return productsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Helper.ProductsCellID, for: indexPath) as! ProductMainTVCell
        let product = (self.searchController.isActive == true) ? self.searchedProducts[indexPath.row] : productsSectionedData[indexPath.section][indexPath.row]
        cell.userInfoLbl.attributedText = getAttributedText(Titles: [product.name?.capitalizingFirstLetter() ?? "N/A", "Cost: \((product.productCost ?? 0.0).getRounded(uptoPlaces: 2))€", "Sale Price: \((product.productSalePrice ?? 0.0).getRounded(uptoPlaces: 2))€"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 12.0),UIFont.systemFont(ofSize: 12.0)], Colors: [UIColor.primaryColor, UIColor.gray, UIColor.gray], seperator: ["\n","\n",""], Spacing: 3, atIndex: 0)
        cell.userImgView.pin_updateWithProgress = true
        cell.userImgView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"), placeholderImage: #imageLiteral(resourceName: "Placeholder Image"))
        return cell
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.searchController.isActive == true {
            return []
        }
        return self.uniqueInitials
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.isActive == true {
            return "Searched Results"
        }
        if isGroupedProductsEnabled {
            return groupedProducts[section].groupedProductName ?? "-"
        }
        return self.uniqueInitials[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            hView.contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
            hView.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            hView.textLabel?.textColor = UIColor.primaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.productsTblView.deselectRow(at: indexPath, animated: true)
        if self.searchController.isActive == true {
            let product = searchedProducts[indexPath.row]
            self.searchController.isActive = false
            performSegue(withIdentifier: Helper.ProductDetailsSegueID, sender: product)
            return
        }
        if isForProductVendor == false {
            performSegue(withIdentifier: Helper.ProductDetailsSegueID, sender: productsSectionedData[indexPath.section][indexPath.row])
        } else {
            performSegue(withIdentifier: Helper.AddVendorProductSegueID, sender: productsSectionedData[indexPath.section][indexPath.row])
        }
        
    }
    
}

extension ProductsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchedProducts = self.products.filter({ $0.name!.contains(searchController.searchBar.text!) })
        self.productsTblView.reloadData()
    }
}
