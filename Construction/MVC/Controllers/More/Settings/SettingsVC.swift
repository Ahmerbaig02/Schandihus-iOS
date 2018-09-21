//
//  SettingsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class SettingsVC: UIViewController {

    @IBOutlet weak var settingsTblView: UITableView!
    
    var lookup: LookupData! {
        didSet {
            setValues()
            settingsTblView.reloadData()
        }
    }
    var bankTitles: [String] = ["Bank Name","Bank Code","Account No."]
    var bankDescripts: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.settingsTblView.delegate = self
        self.settingsTblView.dataSource = self
        configureCell()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getSettingsFromManager()
    }
    
    fileprivate func setValues() {
        bankDescripts.removeAll()
        bankDescripts.append(lookup.companyInfo?.COMPANY_BANK_NAME ?? "Not Added")
        bankDescripts.append(lookup.companyInfo?.COMPANY_BANK_BRANCH_CODE ?? "Not Added")
        bankDescripts.append(lookup.companyInfo?.COMPANY_ACCOUNT_NUMBER ?? "Not Added")
        
    }
    
    fileprivate func configureCell() {
        let cellNib = UINib.init(nibName: "UserInfoTVC", bundle: nil)
        settingsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }

    fileprivate func getSettingsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetSettingsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<LookupData>?, error) in
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.lookup = data?.data ?? nil
            } else {
                print("Error fetching data")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? UpdateSettingsVC {
            destinationVC.companyData = sender as! LookupData
        }
    }
    
    @IBAction func editSettings(_ sender: Any) {
        performSegue(withIdentifier: Helper.UpdateSettingsSegueID, sender: lookup)
    }
    
    deinit {
        print("deinit SettingsVC")
    }
    
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        if lookup == nil {
            return 0
        } else {
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return bankTitles.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Company Info"
        } else if section == 1 {
            return "Bank Info"
        } else {
            return "Description"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = settingsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! UserInfoTVC
            cell.userImgView.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [lookup.companyInfo?.COMPANY_BANK_NAME ?? "No Name",lookup.companyInfo?.COMPANY_ADDRESS ?? "No Address"], Font: [UIFont.systemFont(ofSize: 16.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 13.0)], Colors: [UIColor.primaryColor, UIColor.black], seperator: ["\n",""], Spacing: 3, atIndex: 0)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = settingsTblView.dequeueReusableCell(withIdentifier: Helper.SettingsCellID, for: indexPath)
            cell.textLabel?.text = bankTitles[indexPath.row]
            cell.detailTextLabel?.text = bankDescripts[indexPath.row]
            return cell
            
        } else {
            let cell = settingsTblView.dequeueReusableCell(withIdentifier: Helper.SettingsCellID, for: indexPath)
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 13.0)
            cell.textLabel?.text = lookup.companyInfo?.COMPANY_INFO ?? "No description"
            cell.detailTextLabel?.isHidden = true
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
        self.settingsTblView.deselectRow(at: indexPath, animated: true)
    }
}


