//
//  ProductDetailsVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 19/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Alamofire

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.productDetailsTblView.delegate = self
        self.productDetailsTblView.dataSource = self
        self.configureCell()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.getProductDetailsFromManager()
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
            paramTitles.append("No parameters")
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
    }
    
    fileprivate func getProductDetailsFromManager() {
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: "\(Helper.GetProductDetailsURL)/\(product.productId ?? 0)", method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<ProductData>?, error) in
            if let err = error {
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data ?? "Error fetching data")
                self?.product = data?.data ?? nil
                self?.setValues()
                self?.productDetailsTblView.reloadData()

            } else {
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
            cell.userImgView.image = #imageLiteral(resourceName: "baseline_account_circle_black_24pt")
            cell.userInfoLbl.attributedText = getAttributedText(Titles: [product.name ?? "N/A","Product ID: \(String(product.productId ?? 0))","\(String(product.minimumRetailPrice ?? 0))$ - \(String(product.maximumRetailPrice ?? 0))$"], Font: [UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.semibold), UIFont.systemFont(ofSize: 14.0),UIFont.systemFont(ofSize: 14.0)], Colors: [UIColor.black, UIColor.black,UIColor.black], seperator: ["\n","\n",""], Spacing: 2, atIndex: 0)
            return cell
            
        } else if indexPath.section == 1 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
            cell.textLabel?.text = product.description ?? "No Description Added"
            return cell
            
        } else if indexPath.section == 2 {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.textLabel?.attributedText = getAttributedText(Titles: [paramTitles[indexPath.row],paramDescripts[indexPath.row]], Font: [UIFont.systemFont(ofSize: 15.0),UIFont.systemFont(ofSize: 15.0)], Colors: [UIColor.black,UIColor.black], seperator: ["\t\t\t\t\t",""], Spacing: 2, atIndex: 0)
            return cell
            
        } else {
            let cell = productDetailsTblView.dequeueReusableCell(withIdentifier: Helper.ProductDetailsCellID, for: indexPath)
            cell.textLabel?.text = groupedProducts[indexPath.row]
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15.0)
            return cell
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
    }
}
