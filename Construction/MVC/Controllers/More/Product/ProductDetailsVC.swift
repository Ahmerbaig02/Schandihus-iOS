//
//  ProductDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire
import PINRemoteImage

class ProductDetailsVC: UIViewController {

    @IBOutlet weak var productDetailsTblView: UITableView!
    @IBOutlet weak var vendorsBtn: UIBarButtonItem!
    @IBOutlet weak var addBtn: UIBarButtonItem!
    
    var product: ProductData! = ProductData()
    var grouped: [ProductData]! = []
    var params: [ParamsData]! = []
    var paramTitles: [String] = []
    var paramDescripts: [String] = []
    var groupedProducts : [String] = []
    
    fileprivate lazy var addParameterBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addProductParametersAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    fileprivate lazy var addGroupProductBtn: UIButton = {
        let button = UIButton()
        button.sizeToFit()
        button.addTarget(self, action: #selector(self.addGroupedProductsAction(btn:)), for: .touchUpInside)
        button.tintColor = UIColor.primaryColor
        button.setImage(#imageLiteral(resourceName: "baseline_add_circle_black_24pt"), for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productDetailsTblView.delegate = self
        self.productDetailsTblView.dataSource = self
        self.configureCell()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getProductParamsFromManager()
        self.getProductDetailsFromManager()
    }
    
    @objc fileprivate func addProductParametersAction(btn: UIButton) {
        self.performSegue(withIdentifier: Helper.AddProductParametersSegueID, sender: nil)
    }
    
    @objc fileprivate func addGroupedProductsAction(btn: UIButton) {
        self.performSegue(withIdentifier: Helper.AddGroupedProductsSegueID, sender: nil)
    }
    
    fileprivate func setValues() {
        paramTitles.removeAll()
        paramDescripts.removeAll()
        groupedProducts.removeAll()
        if params.count != 0 {
            let count = params.count-1
            for index in 0...count {
                let param = params[index]
                paramTitles.append(param.parameterName!)
                paramDescripts.append("\(param.parameterValue!) \(param.parameterUnit!)")
            }
        } else {
            paramTitles.append("No Product Parameters")
            paramDescripts.append("")
        }
        if grouped.count != 0 {
            let count = grouped.count-1
            for index in 0...count {
                let product = grouped[index]
                groupedProducts.append(product.name!)
            }
        } else {
            groupedProducts.append("No Grouped Products")
        }
        productDetailsTblView.reloadData()
    }
    
    func configureCell() {
        let cellNib = UINib.init(nibName: "UserInfoTVC", bundle: nil)
        productDetailsTblView.register(cellNib, forCellReuseIdentifier: Helper.UserInfoCellID)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? VendorsVC {
            destinationVC.isForVendorProduct = true
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? ProductVendorsVC {
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? AddParamsVC {
            destinationVC.product = product!
        }
        if let destinationVC = segue.destination as? GroupedProductsVC {
            destinationVC.product = product!
            destinationVC.selectedProducts = grouped ?? []
        }
    }
    
    func showDeleteAlert(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Parameter", message: "Are you sure you want to delete this parameter?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] (action) in
            self?.deleteParametersFromManager(indexPath: indexPath)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    fileprivate func getProductDetailsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductDetailsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<ProductData>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.product = data?.data ?? nil
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getProductParamsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductParamsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ParamsData]>?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.params = list?.data ?? []
                self?.product.ProductParameter = list?.data ?? []
                self?.getGroupedProductsFromManager()
            } else {
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func getGroupedProductsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetGroupedProductsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (list: BasicResponse<[ProductData]>?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print(list?.data ?? "Error fetching data")
                self?.grouped = list?.data ?? []
                self?.setValues()
            } else {
                print("Error fetching data")
            }
        }
    }
    
    fileprivate func deleteParametersFromManager(indexPath: IndexPath) {
        let param = params[indexPath.row]
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetProductParamsURL, method: .delete, headers: nil, encoding: JSONEncoding.default, parameters: ["productId": product.productId ?? 0, "parameterName": param.parameterName ?? ""]) { [weak self] (list: BaseResponse?, error) in
            if let err = error {
                print(err)
                return
            }
            if list?.success == true {
                print("Error")
                self?.params.remove(at: indexPath.row)
                self?.paramTitles.remove(at: indexPath.row)
                self?.paramDescripts.remove(at: indexPath.row)
                self?.productDetailsTblView.deleteRows(at: [indexPath], with: .fade)
            } else {
                print("Error fetching data")
            }
        }
    }
    
    
    @IBAction func showProductVendorsAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.ProductVendorsSegueID, sender: nil)
    }
    
    @IBAction func addProductVendorsAction(_ sender: Any) {
        performSegue(withIdentifier: Helper.ShowVendorsSegueID, sender: nil)
    }
    
    deinit {
        print("deinit ProductDetailsVC")
    }

}

extension ProductDetailsVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 1
        } else if section == 2 {
            return paramTitles.count
        } else {
            return groupedProducts.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Product Info"
        } else if section == 1 {
            return "Description"
        } else if section == 2 {
            return "Parameters"
        } else {
            return "Grouped Products"
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.UserInfoCellID, for: indexPath) as! UserInfoTVC
            cell.userImgView.pin_setImage(from: URL.init(string: "\(Helper.GetProductImageURL)\(product.productId!).jpg"))
            
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [product.name ?? "N/A","Product ID: \(String(product.productId ?? 0))","\(String(product.minimumRetailPrice ?? 0))$ - \(String(product.maximumRetailPrice ?? 0))$"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 14.0),UIFont.systemFont(ofSize: 14.0)], Colors: [UIColor.primaryColor, UIColor.black, UIColor.black], seperator: ["\n","\n",""], Spacing: 5, atIndex: 0)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = product.description ?? "No Description Added"
            return cell
            
        } else if indexPath.section == 2 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            if self.params.count == 0 {
                cell.textLabel?.textColor = UIColor.black
            } else {
                cell.textLabel?.textColor = UIColor.primaryColor
            }
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            cell.textLabel?.text = paramTitles[indexPath.row]
            cell.detailTextLabel?.text = paramDescripts[indexPath.row]
            return cell
            
        } else {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.textLabel?.text = groupedProducts[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold)
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13.0, weight: UIFont.Weight.medium)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hView = view as? UITableViewHeaderFooterView {
            if section == 2 || section == 3 {
                let addBtn = (section == 2) ? addParameterBtn : addGroupProductBtn
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return getCellHeaderSize(Width: self.view.frame.width, aspectRatio: 350/90, padding: 20).height
        }
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.productDetailsTblView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 3 {
            let controller = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsVC") as! ProductDetailsVC
            controller.product = self.grouped[indexPath.row]
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            showDeleteAlert(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 {
            return true
        }
        return false
    }
    
    
}
