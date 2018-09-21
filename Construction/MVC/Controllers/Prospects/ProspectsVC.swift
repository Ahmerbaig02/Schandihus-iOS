//
//  ProspectsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

class ProspectsVC: UIViewController {

    @IBOutlet weak var prospectsTblView: UITableView!
    
    var prospects : [ProspectData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var prospectsSectionedData:[[ProspectData]] = []
    var uniqueInitials: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prospectsTblView.sectionIndexColor = UIColor.primaryColor
        self.prospectsTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.prospectsTblView.delegate = self
        self.prospectsTblView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getProspectListFromManager()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? ProspectDetailsVC {
            let indexPath = sender as! IndexPath
            destinationVC.prospect = prospectsSectionedData[indexPath.section][indexPath.row]
        }
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.prospectsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(prospects.map({ String($0.prospectName!.first!) })).sorted()
        for initial in uniqueInitials {
            self.prospectsSectionedData.append(self.prospects.filter({ String($0.prospectName!.first!) == initial }))
        }
        self.prospectsTblView.reloadData()
    }
    
    fileprivate func getProspectListFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProspectsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProspectData]>?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.prospects = list?.data ?? []
            } else {
                print("Error fetching data")
            }
        }
    }
    
    @IBAction func addProspectAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.AddProspectSegueID, sender: nil)
    }
    
    deinit {
        print("deinit ProspectsVC")
    }


}

extension ProspectsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.prospectsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return prospectsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prospectsTblView.dequeueReusableCell(withIdentifier: Helper.ProspectsCellID, for: indexPath)
        cell.textLabel?.text = prospectsSectionedData[indexPath.section][indexPath.row].prospectName ?? ""
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
        self.prospectsTblView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Helper.ProspectDetailsSegueID, sender: indexPath)
    }
    
}
