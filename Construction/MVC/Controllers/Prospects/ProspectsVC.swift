//
//  ProspectsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

protocol ProspectDelegate: class {
    func Prospects(controller: ProspectsVC, prospect: ProspectData)
}

class ProspectsVC: UIViewController {

    @IBOutlet weak var prospectsTblView: UITableView!
    
    weak var delegate: ProspectDelegate?
    
    var prospects : [ProspectData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var prospectsSectionedData:[[ProspectData]] = []
    var uniqueInitials: [String] = []
    
    var searchedProspects: [ProspectData] = []
    fileprivate var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupSearchController()
        
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
            let prospect = sender as! ProspectData
            destinationVC.prospect = prospect
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.searchController.isActive = false
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
        self.prospectsSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(prospects.map({ String($0.prospectName!.capitalized.first!) })).sorted()
        for initial in uniqueInitials {
            self.prospectsSectionedData.append(self.prospects.filter({ String($0.prospectName!.capitalized.first!) == initial }))
        }
        self.prospectsTblView.reloadData()
    }
    
    fileprivate func getProspectListFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProspectsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProspectData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.prospects = list?.data ?? []
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
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
        if self.searchController.isActive == true {
            return 1
        }
        return self.prospectsSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.searchController.isActive == true {
            return searchedProspects.count
        }
        return prospectsSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = prospectsTblView.dequeueReusableCell(withIdentifier: Helper.ProspectsCellID, for: indexPath)
        let prospect = (self.searchController.isActive == true) ? self.searchedProspects[indexPath.row] : prospectsSectionedData[indexPath.section][indexPath.row]
        cell.tintColor = UIColor.darkGray
        cell.imageView?.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
        cell.textLabel?.text = prospect.prospectName?.capitalizingFirstLetter() ?? ""
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
        return cell
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
        self.prospectsTblView.deselectRow(at: indexPath, animated: true)
        if self.searchController.isActive == true {
            let prospect = searchedProspects[indexPath.row]
            self.searchController.isActive = false
            if delegate != nil {
                delegate?.Prospects(controller: self, prospect: prospect)
                return
            }
            performSegue(withIdentifier: Helper.ProspectDetailsSegueID, sender: prospect)
            return
        }
        if delegate != nil {
            delegate?.Prospects(controller: self, prospect: prospectsSectionedData[indexPath.section][indexPath.row])
            return
        }
        performSegue(withIdentifier: Helper.ProspectDetailsSegueID, sender: prospectsSectionedData[indexPath.section][indexPath.row])
    }
    
}

extension ProspectsVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchedProspects = self.prospects.filter({ $0.prospectName!.contains(searchController.searchBar.text!) })
        self.prospectsTblView.reloadData()
    }
}
