//
//  MoreVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

class MoreVC: UIViewController {

    @IBOutlet weak var settingsTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        self.settingsTblView.delegate = self
        self.settingsTblView.dataSource = self
    }

    deinit {
        print("deinit MoreVC")
    }

}

extension MoreVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = settingsTblView.dequeueReusableCell(withIdentifier: Helper.MoreCellID, for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Products"
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_local_offer_black_18pt")
            cell.imageView?.tintColor = UIColor.gray
            
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Vendors"
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_card_travel_black_18pt")
            cell.imageView?.tintColor = UIColor.gray
            
        } else if indexPath.row == 2 {
            cell.textLabel?.text = "Settings"
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_settings_black_18pt")
            cell.imageView?.tintColor = UIColor.gray
            
        } else {
            cell.textLabel?.text = "Logout"
            cell.imageView?.image = #imageLiteral(resourceName: "baseline_power_settings_new_black_18pt")
            cell.imageView?.tintColor = UIColor.gray
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            performSegue(withIdentifier: Helper.ProductsSegueID, sender: nil)
            
        } else if indexPath.row == 1 {
            performSegue(withIdentifier: Helper.VendorsSegueID, sender: nil)
            
        } else if indexPath.row == 2 {
            performSegue(withIdentifier: Helper.SettingsSegueID, sender: nil)
            
        } else {
            UserDefaults.standard.set(false, forKey: Helper.isLoggedInDefaultID)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
