//
//  AddEstimateVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 03/10/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import SwiftValidator

class AddEstimateVC: UIViewController {

    @IBOutlet weak var estimateTblView: UITableView!
    @IBOutlet weak var totalView: UIView!
    @IBOutlet weak var totalLbl: UILabel!
    
    var prospect: ProspectData = ProspectData()
    var products: [ProductData] = []
    var validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.estimateTblView.delegate = self
        self.estimateTblView.dataSource = self
        
        totalLbl.text = "450 NOK"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.estimateTblView.reloadData()
    }
    
    fileprivate func validateInputs() {
        self.validateFields(validator: self.validator) { [weak self] (success) in
            if success {
                for (_, rule) in self!.validator.validations {
                    if let field = rule.field as? ConstructionTextField {
                        field.errorMessage = nil
                    }
                }
            }
        }
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
            destinationVC.delegate = self
        }
        if let destinationVC = segue.destination as? ProspectsVC {
            destinationVC.delegate = self
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
            return 1
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
                    addBtn.removeFromSuperview()
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
            validator.registerField(cell.estimateNameTF, rules: [RequiredRule()])
            validator.registerField(cell.estimateDateTF, rules: [RequiredRule()])
            validator.registerField(cell.closingDateTF, rules: [RequiredRule()])
            validator.registerField(cell.priceGuaranteeDateTF, rules: [RequiredRule()])
            return cell
            
        } else if indexPath.section == 1 {
            let cell = estimateTblView.dequeueReusableCell(withIdentifier: Helper.AddEstimatesCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            if prospect.prospectId == nil {
                cell.textLabel?.text = "No Prospect"
                cell.detailTextLabel?.isHidden = true
            } else {
                cell.textLabel?.text = prospect.prospectName ?? ""
                cell.detailTextLabel?.text = prospect.homeAddress ?? ""
                cell.detailTextLabel?.isHidden = false
            }
            return cell
        } else {
            let cell = estimateTblView.dequeueReusableCell(withIdentifier: Helper.AddEstimatesCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            if products.count == 0 {
                cell.textLabel?.text = "No Products"
                cell.detailTextLabel?.isHidden = true
            } else {
                cell.textLabel?.text = products[indexPath.row].name ?? ""
                cell.detailTextLabel?.text = "Min \(String(products[indexPath.row].minimumRetailPrice ?? 0)) - Max \(String(products[indexPath.row].maximumRetailPrice ?? 0))"
                cell.detailTextLabel?.isHidden = false
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}

extension AddEstimateVC: ProductDelegate, ProspectDelegate {
    
    func GroupedProducts(controller: GroupedProductsVC, products: [ProductData]) {
        self.products = products
        self.navigationController?.popViewController(animated: true)
    }
    
    func Prospects(controller: ProspectsVC, prospect: ProspectData) {
        self.prospect = prospect
        self.navigationController?.popViewController(animated: true)
    }
    
    
}


