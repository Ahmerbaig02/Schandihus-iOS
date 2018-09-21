//
//  VendorDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class VendorDetailsVC: UIViewController {

    @IBOutlet weak var vendorDetailsTblView: UITableView!
    
    var vendor: VendorData!
    var accountTitles: [String] = ["VAT Number","Priority","Status","Address"]
    var accountDescripts: [String] = ["","","",""]
    var bankTitles: [String] = ["Bank Name","Bank Account Number","Bank Code"]
    var bankDescripts: [String] = ["","",""]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.vendorDetailsTblView.delegate = self
        self.vendorDetailsTblView.dataSource = self
        configureCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getVendorDetailsFromManager()
    }

    fileprivate func setValues() {
        accountDescripts.removeAll()
        bankDescripts.removeAll()
        accountDescripts.append(vendor?.vatNumber ?? "Not Added")
        accountDescripts.append(vendor?.priority ?? "Not Added")
        accountDescripts.append(vendor?.status ?? "Not Added")
        accountDescripts.append(vendor?.address ?? "Not Added")
        bankDescripts.append(vendor?.bankName ?? "Not Added")
        bankDescripts.append(vendor?.bankAccountNumber ?? "Not Added")
        bankDescripts.append(vendor?.bankCode ?? "Not Added")
        
    }
    
    fileprivate func configureCell() {
        let cellNib = UINib.init(nibName: "UserInfoTVC", bundle: nil)
        vendorDetailsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddVendorVC {
            destinationVC.vendor = (sender as! VendorData)
        }
        if let destinationVC = segue.destination as? VendorProductsVC {
            destinationVC.vendor = vendor
        }
    }
    
    fileprivate func getVendorDetailsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetVendorDetailsURL)/\(vendor.vendorId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<VendorData>?, error) in
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.vendor = data?.data ?? nil
                self?.setValues()
                self?.vendorDetailsTblView.reloadData()
            } else {
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func editVendorDetails(_ sender: Any) {
        performSegue(withIdentifier: Helper.EditVendorSegueID, sender: vendor)
    }
    
    @IBAction func showVendorProductsAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.VendorProductsSegueID, sender: nil)
    }
    
    @IBAction func addVendorProductAction(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "ProductsVC") as! ProductsVC
        self.navigationController?.pushViewController(controller, animated: true)
        controller.isForProductVendor =  true
        controller.vendor = vendor
    }
    
    deinit {
        print("deinit VendorDetailsVC")
    }
    
}

extension VendorDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return accountTitles.count
        } else {
            return bankTitles.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "User Info"
        } else if section == 1 {
            return "Account Info"
        } else {
            return "Bank Info"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = vendorDetailsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! UserInfoTVC
            cell.userImgView.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [vendor?.name ?? "No Name","N/A"], Font: [UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 13.0)], Colors: [UIColor.primaryColor, UIColor.black], seperator: ["\n",""], Spacing: 3, atIndex: 0)
            return cell

        } else if indexPath.section == 1 {
            let cell = vendorDetailsTblView.dequeueReusableCell(withIdentifier: Helper.VendorDetailsCellID, for: indexPath)
            cell.textLabel?.text = accountTitles[indexPath.row]
            cell.detailTextLabel?.text = accountDescripts[indexPath.row]
            return cell
            
        } else {
            let cell = vendorDetailsTblView.dequeueReusableCell(withIdentifier: Helper.VendorDetailsCellID, for: indexPath)
            cell.textLabel?.text = bankTitles[indexPath.row]
            cell.detailTextLabel?.text = bankDescripts[indexPath.row]
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return getCellHeaderSize(Width: self.view.frame.width, aspectRatio: 300/80, padding: 20).height
        }
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.vendorDetailsTblView.deselectRow(at: indexPath, animated: true)
    }
}