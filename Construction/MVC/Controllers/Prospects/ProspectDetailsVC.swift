//
//  ProspectDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 02/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class ProspectDetailsVC: UIViewController {

    @IBOutlet weak var prospectDetailsTblView: UITableView!
    
    var prospect: ProspectData! = ProspectData()
    var accountTitles: [String] = ["Work Address","Home Address","Status"]
    var accountDescripts: [String] = ["","",""]
    var estimates: [EstimateData] = []
    var estimateList = [EstimateData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prospectDetailsTblView.delegate = self
        self.prospectDetailsTblView.dataSource = self
        configureCell()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getProspectDetailsFromManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? AddProspectVC {
            controller.prospect = self.prospect
        }
    }
    
    fileprivate func setValues() {
        accountDescripts.removeAll()
        accountDescripts.append(prospect?.workAddress ?? "Not Work Address")
        accountDescripts.append(prospect?.homeAddress ?? "Not Home Address")
        accountDescripts.append(prospect?.status ?? "Not Status")
        
    }
    
    fileprivate func configureCell() {
        let cellNib = UINib.init(nibName: "UserInfoTVC", bundle: nil)
        prospectDetailsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }

    fileprivate func getProspectDetailsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProspectsURL)/\(prospect.prospectId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<ProspectData>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.prospect = data?.data ?? nil
                self?.getEstimatesFromManager()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getEstimatesFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetEstimatesURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<[EstimateData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.estimateList = (data?.data ?? nil)!
                self?.estimates = (self?.estimateList.filter({ $0.prospectId == self?.prospect.prospectId!}))!
                self?.setValues()
                self?.prospectDetailsTblView.reloadData()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func editProspectAction(_ sender: Any) {
        self.performSegue(withIdentifier: "EditProspectSegue", sender: nil)
    }
    
    deinit {
        print("deinit ProspectDetailsVC")
    }
}

extension ProspectDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return accountTitles.count
        } else {
            return estimates.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Info"
        } else if section == 1 {
            return "Account Info"
        } else {
            return "Estimate"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = prospectDetailsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! UserInfoTVC
            cell.userImgView.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [prospect?.prospectName ?? "No Name",prospect.contactNumber ?? "N/A"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.bold), UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)], Colors: [UIColor.primaryColor, UIColor.black], seperator: ["\n",""], Spacing: 5, atIndex: 0)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = prospectDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProspectDetailsCellID, for: indexPath)
            cell.textLabel?.textColor = UIColor.primaryColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = accountTitles[indexPath.row]
            cell.detailTextLabel?.text = accountDescripts[indexPath.row]
            return cell
            
        } else {
            let cell = prospectDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProspectDetailsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = estimates[indexPath.row].projectName ?? ""
            cell.detailTextLabel?.text = String(estimates[indexPath.row].volume ?? 0.0)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            hView.contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
            hView.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            hView.textLabel?.textColor = UIColor.primaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return getCellHeaderSize(Width: self.view.frame.width, aspectRatio: 300/80, padding: 20).height
        }
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.prospectDetailsTblView.deselectRow(at: indexPath, animated: true)
    }
}
