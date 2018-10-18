//
//  EstimateVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire
import DropDown

class EstimateVC: UIViewController {
    
    @IBOutlet weak var estimatesTblView: UITableView!
    
    var estimates: [EstimateData] = [] {
        didSet {
            self.makeSectionIndicesOnFirstLetter()
        }
    }
    var estimatesSectionedData:[[EstimateData]] = []
    var uniqueInitials: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.estimatesTblView.register(EstimateTVCell.self, forCellReuseIdentifier: Helper.EstimatesCellID)
        
        self.estimatesTblView.sectionIndexColor = UIColor.primaryColor
        self.estimatesTblView.sectionIndexBackgroundColor = UIColor.groupTableViewBackground
        self.estimatesTblView.delegate = self
        self.estimatesTblView.dataSource = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getEstimatesFromManager()
    }
    
    fileprivate func makeSectionIndicesOnFirstLetter() {
        self.estimatesSectionedData.removeAll()
        self.uniqueInitials.removeAll()
        uniqueInitials = Set(estimates.map({ String($0.projectName!.first! ) })).sorted()
        for initial in uniqueInitials {
            self.estimatesSectionedData.append(self.estimates.filter({ String($0.projectName!.first! ) == initial }))
        }
        self.estimatesTblView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? EstimateDetailsVC {
            let indexPath = sender as! IndexPath
            let estimate = estimatesSectionedData[indexPath.section][indexPath.row]
            destinationVC.estimateId = estimate.estimateId
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
                self?.estimates = (data?.data ?? []).filter({ $0.projectName != nil && $0.projectName?.isEmpty == false })
                self?.estimatesTblView.reloadData()
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func filterDataBasedOn(type: String) {
        if type == "prospect name" {
            self.estimates = self.estimates.sorted(by: { $0.Prospect!.prospectName! < $1.Prospect!.prospectName! })
        } else if type == "estimate name" {
            self.estimates = self.estimates.sorted(by: { $0.projectName! < $1.projectName! })
        } else if type == "closing date" {
            self.estimates = self.estimates.sorted(by: { $0.closingDate! < $1.closingDate! })
        } else if type == "price gurantee date" {
            self.estimates = self.estimates.sorted(by: { $0.priceGuaranteeDate! < $1.priceGuaranteeDate! })
        }
        makeSectionIndicesOnFirstLetter()
    }
    
    @IBAction func filterEstimatesAction(_ sender: Any) {
        let dropDown = DropDown()
        dropDown.dataSource = ["prospect name", "estimate name", "closing date", "price gurantee date"]
        dropDown.anchorView = sender as! UIBarButtonItem
        dropDown.sizeToFit()
        dropDown.direction = .any
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            self!.filterDataBasedOn(type: item)
        }
        dropDown.show()
    }
    
    @IBAction func addEstimateAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.AddEstimateSegueID, sender: nil)
    }
    
    deinit {
        print("deinit EstimateVC")
    }
    
    
}

extension EstimateVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.estimatesSectionedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return estimatesSectionedData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = estimatesTblView.dequeueReusableCell(withIdentifier: Helper.EstimatesCellID, for: indexPath) as! EstimateTVCell
        cell.delegate = self
        cell.textLabel?.text = estimatesSectionedData[indexPath.section][indexPath.row].projectName ?? ""
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
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
        self.estimatesTblView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: Helper.EstimateDetailsSegueID, sender: indexPath)
    }
    
}

extension EstimateVC: EstimateTVCellDelegate {
    func showQuickInfo(cell: EstimateTVCell) {
        if let indexPath = self.estimatesTblView.indexPath(for: cell) {
            let estimateData = self.estimatesSectionedData[indexPath.section][indexPath.row]
            self.showAlert(title: estimateData.projectName ?? "#Name not available", message: "Estimate Date: \(estimateData.estimateDate?.dateFromISO8601?.humanReadableDate ?? "Not Available")\nClosing Date: \(estimateData.closingDate?.dateFromISO8601?.humanReadableDate ?? "Not Available")\nVolume: \(estimateData.volume?.getRounded(uptoPlaces: 2) ?? "Not Available")")
        }
    }
}
