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
    
    var searchedVendors: [VendorData] = []
    fileprivate var searchController: UISearchController!
    
    struct EstimateData: Codable {
        var prospectId: Int?
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        
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
        
//        navigationItem.searchController?.isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.isActive = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? VendorDetailsVC {
            let vendor = sender as! VendorData
            destinationVC.vendor = vendor
        }
        if let destinationVC = segue.destination as? AddProductVendorsVC {
            let vendor = sender as! VendorData
            destinationVC.product = product
            destinationVC.vendor = vendor
        }
    }
    
    fileprivate func setupSearchController() {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.tintColor = UIColor.black
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        navigationItem.searchController = controller
        navigationItem.hidesSearchBarWhenScrolling = false
        controller.searchBar.sizeToFit()
        
        self.searchController = controller
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.vendorsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(vendors.map({ String($0.name!.capitalized.first!) })).sorted()
        for initial in uniqueInitials {
            self.vendorsSectionedData.append(self.vendors.filter({ String($0.name!.capitalized.first!) == initial }))
        }
        self.vendorsTblView.reloadData()
    }
    
    fileprivate func getVendorListFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetVendorsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[VendorData]>?, error) in
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

    @IBAction func addVendor(_ sender: Any) {
        performSegue(withIdentifier: Helper.AddVendorSegueID, sender: nil)
    }
    
    deinit {
        print("deinit VendorsVC")
    }
    
}

extension VendorsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.searchController.isActive == true {
            return 1
        }
        return vendorsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive == true {
            return self.searchedVendors.count
        }
        return vendorsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = vendorsTblView.dequeueReusableCell(withIdentifier: Helper.VendorsCellID, for: indexPath)
        let vendor = (self.searchController.isActive == true) ? searchedVendors[indexPath.row] : vendorsSectionedData[indexPath.section][indexPath.row]
        cell.textLabel?.text = vendor.name?.capitalizingFirstLetter() ?? ""
        cell.tintColor = UIColor.darkGray
        cell.textLabel?.textColor = UIColor.darkGray
        cell.imageView?.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if self.searchController.isActive == true {
            return nil
        }
        return self.uniqueInitials
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.searchController.isActive == true {
            return "Searched Results"
        }
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
        if self.searchController.isActive == true {
            let vendor = searchedVendors[indexPath.row]
            self.searchController.isActive = false
            performSegue(withIdentifier: Helper.VendorDetailsSegueID, sender: vendor)
            return
        }
        if isForVendorProduct == false {
            performSegue(withIdentifier: Helper.VendorDetailsSegueID, sender: vendorsSectionedData[indexPath.section][indexPath.row])
        } else {
            performSegue(withIdentifier: Helper.AddProductVendorSegueID, sender: vendorsSectionedData[indexPath.section][indexPath.row])
        }
    }
    
}


extension VendorsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchedVendors = self.vendors.filter({ $0.name!.contains(searchController.searchBar.text!) })
        self.vendorsTblView.reloadData()
    }
}
