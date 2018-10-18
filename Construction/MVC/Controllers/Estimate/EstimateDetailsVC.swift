//
//  EstimateDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator
import Alamofire
import PINRemoteImage

class EstimateDetailsVC: UIViewController {

    @IBOutlet weak var estimateDetailsTblView: UITableView!
    
    var estimate: EstimateData! = EstimateData()
    var estimateTitles: [String] = ["Name","Estimate Date","Closing Date","Price Guarantee Date"]
    var prospectTitles: [String] = ["Name","Discount","Status","Contact","Home Address","Work Address"]
    var estimateDescripts: [String] = ["","","",""]
    var prospectDescripts: [String] = ["","","","","",""]
    var products: [ProductData] = []
    var estimateId: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.estimateDetailsTblView.delegate = self
        self.estimateDetailsTblView.dataSource = self
        self.configureCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getEstimateDetailsFromManager()
    }
    
    fileprivate func setValues() {
        estimateDescripts.removeAll()
        prospectDescripts.removeAll()

        estimateDescripts.append(estimate.projectName ?? "N/A")
        estimateDescripts.append(estimate.estimateDate?.dateFromISO8601?.humanReadableDate ?? "N/A")
        estimateDescripts.append(estimate.closingDate?.dateFromISO8601?.humanReadableDate ?? "N/A")
        estimateDescripts.append(estimate.priceGuaranteeDate?.dateFromISO8601?.humanReadableDate ?? "N/A")
        
        prospectDescripts.append(estimate.Prospect?.prospectName ?? "N/A")
        prospectDescripts.append("\(estimate.Prospect?.generalDiscount ?? 0)")
        prospectDescripts.append(estimate.Prospect?.status ?? "N/A")
        prospectDescripts.append(estimate.Prospect?.contactNumber ?? "N/A")
        prospectDescripts.append(estimate.Prospect?.homeAddress ?? "N/A")
        prospectDescripts.append(estimate.Prospect?.workAddress ?? "N/A")
        
        estimateDetailsTblView.reloadData()
    }
    
    func configureCell() {
        let cellNib = UINib.init(nibName: "UserInfoTVC", bundle: nil)
        estimateDetailsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? AddEstimateVC {
            destinationVC.estimate = estimate
            destinationVC.products = products
        }
    }
    
    fileprivate func getEstimateDetailsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetEstimatesURL)/\(estimateId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<EstimateData>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.estimate = data?.data ?? nil
                self?.getEstimateProductsFromManager()
            } else {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getEstimateProductsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetEstimateProductsURL)/\(estimateId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<[ProductData]>?, error) in
            if let err = error {
                UIViewController.hideLoader()
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.products = data?.data ?? []
                self?.setValues()
                UIViewController.hideLoader()
            } else {
                UIViewController.hideLoader()
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func editEstimateAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.EditEstimateSegueID, sender: nil)
    }
    
    deinit {
        print("deinit EstimateDetailsVC")
    }
    
}

extension EstimateDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return estimateDescripts.count
        } else if section == 1 {
            return prospectDescripts.count
        } else {
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Estimate Info"
        } else if section == 1 {
            return "Prospect Info"
        } else {
            return "Products"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = estimateDetailsTblView.dequeueReusableCell(withIdentifier: Helper.EstimateDetailsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.textColor = (estimate == nil) ? UIColor.gray : UIColor.primaryColor
            cell.textLabel?.text = estimateTitles[indexPath.row]
            cell.detailTextLabel?.text = estimateDescripts[indexPath.row]
            return cell
            
        } else if indexPath.section == 1 {
            let cell = estimateDetailsTblView.dequeueReusableCell(withIdentifier: Helper.EstimateDetailsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.textColor = (estimate.Prospect == nil) ? UIColor.gray : UIColor.primaryColor
            if estimate.Prospect == nil {
                cell.textLabel?.text = "No Prospect Added"
                cell.detailTextLabel?.isHidden = true
            } else {
                cell.textLabel?.text = prospectTitles[indexPath.row]
                cell.detailTextLabel?.text = prospectDescripts[indexPath.row]
                cell.detailTextLabel?.isHidden = false
            }
            return cell
            
        } else {
            let cell = estimateDetailsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! UserInfoTVC
            let product = products[indexPath.row]
            cell.userImgView.pin_updateWithProgress = true
            cell.userImgView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"), placeholderImage: #imageLiteral(resourceName: "Placeholder Image"))
            
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [product.name ?? "N/A","\(String(product.minimumRetailPrice ?? 0))$ - \(String(product.maximumRetailPrice ?? 0))$"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold),UIFont.systemFont(ofSize: 14.0)], Colors: [UIColor.primaryColor, UIColor.black], seperator: ["\n",""], Spacing: 5, atIndex: 0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return getCellHeaderSize(Width: self.view.frame.width, aspectRatio: 350/90, padding: 20).height
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.estimateDetailsTblView.deselectRow(at: indexPath, animated: true)
    }
    
}