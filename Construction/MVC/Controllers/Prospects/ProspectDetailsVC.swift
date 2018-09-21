//
//  ProspectDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 02/09/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class ProspectDetailsVC: UIViewController {

    @IBOutlet weak var prospectDetailsTblView: UITableView!
    
    var prospect: ProspectData! = ProspectData()
    var accountTitles: [String] = ["Work Address","Home Address","Status"]
    var accountDescripts: [String] = []
    var estimates: [String] = ["No Estimate"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setValues()
        self.prospectDetailsTblView.delegate = self
        self.prospectDetailsTblView.dataSource = self
        configureCell()
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
            cell.textLabel?.textColor = UIColor.primaryColor
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = estimates[indexPath.row]
            cell.detailTextLabel?.isHidden = true
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
