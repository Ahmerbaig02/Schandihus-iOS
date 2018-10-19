//
//  AddEstimateVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 03/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire
import SwiftValidator

class AddEstimateVC: UIViewController {

    @IBOutlet weak var estimateTblView: UITableView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    var prospect: ProspectData = ProspectData()
    var products: [ProductData] = [ProductData]()
    var estimate: EstimateData?
    var validator = Validator()
    var urlStr: String = Helper.GetEstimatesURL
    var method: HTTPMethod = .post
    
    var isMaxPrice: Bool = false
    var isDiscount: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.estimateTblView.delegate = self
        self.estimateTblView.dataSource = self
        
        totalLbl.text = "0 NOK"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if estimate != nil {
            self.navigationItem.title = "Edit Estimate"
            self.submitBtn.setTitle("Update Estimate", for: .normal)
            prospect = ((estimate?.Prospect ?? nil) ?? nil)!
        } else {
            self.navigationItem.title = "Add Estimate"
            self.submitBtn.setTitle("Add Estimate", for: .normal)
        }
        self.estimateTblView.reloadData()
        var total = self.products.reduce(0, {$0 + $1.minimumRetailPrice!})
        if isMaxPrice {
            total = self.products.reduce(0, {$0 + $1.maximumRetailPrice!})
        }
        if isDiscount {
            if let discount = prospect.generalDiscount {
                total = total - Int(Double(total) * Double(discount)/100)
            }
        }
        totalLbl.text = "\(total) NOK"
    }
    
    fileprivate lazy var addProspectBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addProspectAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    fileprivate lazy var addProductsBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addProductsAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? GroupedProductsVC {
            destinationVC.selectedProducts = self.products
            destinationVC.delegate = self
        }
        if let destinationVC = segue.destination as? ProspectsVC {
            destinationVC.delegate = self
        }
        if let destinationVC = segue.destination as? AddEstimateSettingsVC {
            destinationVC.controller = self
        }
    }
    
    fileprivate func validateInputs() {
        self.validateFields(validator: self.validator) { [weak self] (success) in
            if success {
                for (_, rule) in self!.validator.validations {
                    if let field = rule.field as? ConstructionTextField {
                        field.errorMessage = nil
                    }
                }
                if self!.prospect.prospectId == nil {
                    self!.showBanner(title: "Add Prospect first", style: .danger)
                    return
                }
                if self!.products.count == 0 {
                    self!.showBanner(title: "Add Product(s) first", style: .danger)
                    return
                }
                self!.postEstimateFromManager()
            }
        }
    }

    fileprivate func postEstimateFromManager() {
        if estimate !=  nil {
            urlStr = "\(Helper.GetEstimatesURL)/\(estimate!.estimateId ?? 0)"
            method = .put
        }

        var productIds: [Int] = []
        for index in 0...products.count-1 {
            let product = products[index]
            productIds.append(product.productId ?? 0)
        }
        if let cell = estimateTblView.cellForRow(at: IndexPath(row: 0, section: 0)) as? AddEstimateFieldsCell {
            UIViewController.showLoader(text: "Please Wait...")
            NetworkManager.fetchUpdateGenericDataFromServer(urlString: urlStr, method: method, headers: nil, encoding: JSONEncoding.default, parameters: ["projectName": cell.estimateNameTF.text!.capitalizingFirstLetter(), "prospectId": "\(prospect.prospectId!)", "estimateDate": cell.estimateDate, "closingDate": cell.closingDate, "priceGuaranteeDate": cell.priceGuaranteeDate, "products": productIds]) { [weak self] (response: BaseResponse?, error) in
                UIViewController.hideLoader()
                if let err = error {
                    print(err)
                    return
                }
                if response?.success == true {
                    print("Posted Estimate")
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                    print("Error fetching data")
                }
            }
        }
    }
    
    @objc fileprivate func addProspectAction(btn: UIButton) {
     self.performSegue(withIdentifier: Helper.AddProspectsSegueID, sender: nil)
    }
    
    @objc fileprivate func addProductsAction(btn: UIButton) {
     self.performSegue(withIdentifier: Helper.AddProductsSegueID, sender: nil)
    }
    
    @IBAction func addEstimateAction(_ sender: Any) {
        self.validateInputs()
    }
    
    deinit {
        print("deinit AddEstimateVC")
    }
}

extension AddEstimateVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return self.prospect.prospectId == nil ? 0 : 1
        } else {
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Basic Info"
        } else if section == 1 {
            return "Prospect"
        } else {
            return "Products"
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            if section == 1 || section == 2 {
                let addBtn = (section == 1) ? addProspectBtn : addProductsBtn
                if !hView.subviews.contains(addBtn) {
                    hView.addSubview(addBtn)
                    addBtn.anchor(hView.topAnchor, left: nil, bottom: hView.bottomAnchor, right: hView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 8, widthConstant: 0, heightConstant: 0)
                } else {
                   // addBtn.removeFromSuperview()
                }
            }
            hView.contentView.backgroundColor = UIColor.groupTableViewBackground.withAlphaComponent(0.8)
            hView.textLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.semibold)
            hView.textLabel?.textColor = UIColor.primaryColor
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = estimateTblView.dequeueReusableCell(withIdentifier: Helper.EstimateTextFieldCellID, for: indexPath) as! AddEstimateFieldsCell
            cell.delegate = self
            if estimate != nil {
                cell.estimateName = estimate?.projectName ?? ""
                cell.estimateDate = estimate?.estimateDate ?? ""
                cell.closingDate = estimate?.closingDate ?? ""
                cell.priceGuaranteeDate = estimate?.priceGuaranteeDate ?? ""
                
                cell.estimateNameTF.text = cell.estimateName
                cell.estimateDateTF.text = cell.estimateDate.replacingOccurrences(of: " ", with: "T").dateFromISO8601?.humanReadableDate ?? ""
                cell.closingDateTF.text = cell.closingDate.replacingOccurrences(of: " ", with: "T").dateFromISO8601?.humanReadableDate ?? ""
                cell.priceGuaranteeDateTF.text = cell.priceGuaranteeDate.replacingOccurrences(of: " ", with: "T").dateFromISO8601?.humanReadableDate ?? ""
            }
            cell.validator = self.validator
            validator.registerField(cell.estimateNameTF, rules: [RequiredRule()])
            validator.registerField(cell.estimateDateTF, rules: [RequiredRule()])
            validator.registerField(cell.closingDateTF, rules: [RequiredRule()])
            validator.registerField(cell.priceGuaranteeDateTF, rules: [RequiredRule()])
            return cell
            
        } else if indexPath.section == 1 {
            let cell = estimateTblView.dequeueReusableCell(withIdentifier: Helper.AddEstimatesCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = prospect.prospectName ?? ""
            cell.detailTextLabel?.text = "Address: \(prospect.homeAddress ?? "")\nDiscount: \(prospect.generalDiscount ?? 0) %"
            return cell
        } else {
            let cell = estimateTblView.dequeueReusableCell(withIdentifier: Helper.AddProductsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = products[indexPath.row].name ?? ""
            cell.detailTextLabel?.text = "Min: \(String(products[indexPath.row].minimumRetailPrice ?? 0))\nMax: \(String(products[indexPath.row].maximumRetailPrice ?? 0))"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        estimateTblView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension AddEstimateVC: ProductDelegate, ProspectDelegate, EstimateDelegate {
    
    func GroupedProducts(controller: GroupedProductsVC, products: [ProductData]) {
        self.products = products
        self.navigationController?.popViewController(animated: true)
    }
    
    func Prospects(controller: ProspectsVC, prospect: ProspectData) {
        self.prospect = prospect
        self.navigationController?.popViewController(animated: true)
    }
    
    func EstimateDetails(cell: AddEstimateFieldsCell) {
        estimate?.projectName = cell.estimateName
        estimate?.estimateDate = cell.estimateDate
        estimate?.closingDate = cell.closingDate
        estimate?.priceGuaranteeDate = cell.priceGuaranteeDate
    }
}


