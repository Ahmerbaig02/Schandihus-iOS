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
    var productsSectionedData:[[ProductData]] = []
    var uniqueInitials: [String] = []
    var isForProductVendor: Bool = false
    var vendor: VendorData = VendorData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.productsTblView.sectionIndexColor = UIColor.primaryColor
        self.productsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.productsTblView.delegate = self
        self.productsTblView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getProductListFromManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ProductDetailsVC {
            let indexPath = sender as! IndexPath
            destinationVC.product = productsSectionedData[indexPath.section][indexPath.row]
        }
        if let destinationVC = segue.destination as? AddProductVendorsVC {
            let indexPath = sender as! IndexPath
            destinationVC.vendor = vendor
            destinationVC.product = productsSectionedData[indexPath.section][indexPath.row]
        }
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.productsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(products.map({ String($0.name!.first!) })).sorted()
        for initial in uniqueInitials {
            self.productsSectionedData.append(self.products.filter({ String($0.name!.first!) == initial }))
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
                print(list?.data ?? "Error fetching data")
                self?.products = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func addProduct(_ sender: Any) {
        performSegue(withIdentifier: Helper.AddProductSegueID, sender: nil)
    }
    
    deinit {
        print("deinit ProductsVC")
    }
    

}

extension ProductsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.productsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = productsTblView.dequeueReusableCell(withIdentifier: Helper.ProductsCellID, for: indexPath)
        cell.textLabel?.text = productsSectionedData[indexPath.section][indexPath.row].name ?? ""
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
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
        self.productsTblView.deselectRow(at: indexPath, animated: true)
        if isForProductVendor == false {
            performSegue(withIdentifier: Helper.ProductDetailsSegueID, sender: indexPath)
        } else {
            performSegue(withIdentifier: Helper.AddVendorProductSegueID, sender: indexPath)
        }
        
    }
    
}
