//
//  VendorProductsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 03/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class VendorProductsVC: UIViewController {
    
    @IBOutlet weak var VendorProductsTblView: UITableView!
    
    var vendor: VendorData = VendorData()
    var products : [ProductData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var productSectionedData:[[ProductData]] = []
    var uniqueInitials: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.VendorProductsTblView.sectionIndexColor = UIColor.primaryColor
        self.VendorProductsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.VendorProductsTblView.delegate = self
        self.VendorProductsTblView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getVendorProductsFromManager()
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.productSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(products.map({ String($0.name!.first!) })).sorted()
        for initial in uniqueInitials {
            self.productSectionedData.append(self.products.filter({ String($0.name!.first!) == initial }))
        }
        self.VendorProductsTblView.reloadData()
    }
    
    fileprivate func getVendorProductsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetVendorProductURL)/\(vendor.vendorId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProductData]>?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.products = list?.data ?? []
            } else {
                print("Error fetching data")
            }
        }
    }
    
    deinit {
        print("deinit ProductVendorsVC")
    }
    
}

extension VendorProductsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return productSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = VendorProductsTblView.dequeueReusableCell(withIdentifier: Helper.VendorProductsCellID, for: indexPath)
        cell.textLabel?.text = productSectionedData[indexPath.section][indexPath.row].name ?? ""
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
        self.VendorProductsTblView.deselectRow(at: indexPath, animated: true)
        let controller = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
        self.navigationController?.pushViewController(controller, animated: true)
        controller.product = productSectionedData[indexPath.section][indexPath.row]
        controller.addBtn.isEnabled = false
        controller.addBtn.title = ""
        controller.vendorsBtn.isEnabled = false
        controller.vendorsBtn.title = ""
    }
    
}
