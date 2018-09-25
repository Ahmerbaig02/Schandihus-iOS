//
//  ProductVendorsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 03/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class ProductVendorsVC: UIViewController {

    @IBOutlet weak var ProductvendorsTblView: UITableView!
    
    var product: ProductData = ProductData()
    var vendors : [VendorData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var vendorsSectionedData:[[VendorData]] = []
    var uniqueInitials: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ProductvendorsTblView.sectionIndexColor = UIColor.primaryColor
        self.ProductvendorsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.ProductvendorsTblView.delegate = self
        self.ProductvendorsTblView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getProductVendorsFromManager()
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.vendorsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(vendors.map({ String($0.name!.first!) })).sorted()
        for initial in uniqueInitials {
            self.vendorsSectionedData.append(self.vendors.filter({ String($0.name!.first!) == initial }))
        }
        self.ProductvendorsTblView.reloadData()
    }
    
    fileprivate func getProductVendorsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductVendorURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[VendorData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.vendors = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    deinit {
        print("deinit ProductVendorsVC")
    }
    
}

extension ProductVendorsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vendorsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendorsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ProductvendorsTblView.dequeueReusableCell(withIdentifier: Helper.ProductVendorsCellID, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        cell.textLabel?.text = vendorsSectionedData[indexPath.section][indexPath.row].name ?? ""
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
        self.ProductvendorsTblView.deselectRow(at: indexPath, animated: true)
        let controller = storyboard?.instantiateViewController(withIdentifier: "VendorDetailsVC") as! VendorDetailsVC
        controller.vendor = vendorsSectionedData[indexPath.section][indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
