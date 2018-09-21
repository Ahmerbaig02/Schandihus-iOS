//
//  VendorsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class VendorsVC: UIViewController {

    @IBOutlet weak var vendorsTblView: UITableView!
    @IBOutlet weak var addVendorBtn: UIBarButtonItem!
    
    var vendors : [VendorData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var vendorsSectionedData:[[VendorData]] = []
    var uniqueInitials: [String] = []
    var isForVendorProduct: Bool = false
    var product: ProductData = ProductData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.vendorsTblView.sectionIndexColor = UIColor.primaryColor
        self.vendorsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.vendorsTblView.delegate = self
        self.vendorsTblView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isForVendorProduct == true {
            self.addVendorBtn.isEnabled = false
            self.addVendorBtn.image = nil
        }
        getVendorListFromManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? VendorDetailsVC {
            let indexPath = sender as! IndexPath
            destinationVC.vendor = vendorsSectionedData[indexPath.section][indexPath.row]
        }
        if let destinationVC = segue.destination as? AddProductVendorsVC {
            let indexPath = sender as! IndexPath
            destinationVC.product = product
            destinationVC.vendor = vendorsSectionedData[indexPath.section][indexPath.row]
        }
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.vendorsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(vendors.map({ String($0.name!.first!) })).sorted()
        for initial in uniqueInitials {
            self.vendorsSectionedData.append(self.vendors.filter({ String($0.name!.first!) == initial }))
        }
        self.vendorsTblView.reloadData()
    }
    
    fileprivate func getVendorListFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetVendorsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[VendorData]>?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.vendors = list?.data ?? []
            } else {
                print("Error fetching data")
            }
        }
    }

    @IBAction func addVendor(_ sender: Any) {
        performSegue(withIdentifier: Helper.AddVendorSegueID, sender: nil)
    }
    
    deinit {
        print("deinit VendorsVC")
    }
    
}

extension VendorsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return vendorsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendorsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = vendorsTblView.dequeueReusableCell(withIdentifier: Helper.VendorsCellID, for: indexPath)
        cell.textLabel?.text = vendorsSectionedData[indexPath.section][indexPath.row].name ?? ""
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
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
        self.vendorsTblView.deselectRow(at: indexPath, animated: true)
        if isForVendorProduct == false {
            performSegue(withIdentifier: Helper.VendorDetailsSegueID, sender: indexPath)
        } else {
            performSegue(withIdentifier: Helper.AddProductVendorSegueID, sender: indexPath)
        }
    }
    
}
