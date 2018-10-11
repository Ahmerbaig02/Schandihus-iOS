//
//  DashboardVC.swift
//  Construction
//
//  Created by Mahnoor Fatima on 17/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit
import Parchment
import Alamofire
import Crashlytics

class DashboardVC: UIViewController {
    
    fileprivate var pagingViewControllers: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupControllers()
        self.getSettingsFromManager()
        
        
        Crashlytics.sharedInstance().crash()

    }
    
    
    fileprivate func setupControllers() {
        let probsVC = storyboard?.instantiateViewController(withIdentifier: "RelativeProbabilitiesVC") as! RelativeProbabilitiesVC
        probsVC.parentVC = self
        let estVC = storyboard?.instantiateViewController(withIdentifier: "DashboardEstimateVC") as! DashboardEstimateVC
        estVC.parentVC = self
        let volumeVC = storyboard?.instantiateViewController(withIdentifier: "ForcastedVolumesVC") as! ForcastedVolumesVC
        volumeVC.parentVC = self
        
        pagingViewControllers = [ probsVC, estVC, volumeVC ]
        
        let pageVC = FixedPagingViewController(viewControllers: pagingViewControllers)
        
        pageVC.selectedTextColor = UIColor.primaryColor
        pageVC.indicatorColor = UIColor.primaryColor
        pageVC.textColor = UIColor.lightGray
        pageVC.indicatorOptions = .visible(
            height: 1,
            zIndex: Int.max - 1, spacing: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8),
            insets: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
        
        pageVC.view.tintColor = UIColor.primaryColor
        self.addChildViewController(pageVC)
        self.view.addSubview(pageVC.view)
        pageVC.didMove(toParentViewController: self)
        pageVC.view.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    fileprivate func getSettingsFromManager() {
        UIViewController.showLoader(text: "Please Wait...")
        NetworkManager.fetchUpdateGenericDataFromServer(urlString: Helper.GetSettingsURL, method: .get, headers: nil, encoding: JSONEncoding.default, parameters: nil) { [weak self] (data: BasicResponse<[LookupData]>?, error) in
            UIViewController.hideLoader()
            if let err = error {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print(err)
                return
            }
            if data?.success == true {
                print(data?.data?.first ?? "Error fetching data")
                LookupData.shared = data?.data?.first
            } else {
                self!.showBanner(title: "An Error occurred. Please try again later.", style: .danger)
                print("Error fetching data")
            }
        }
    }

    
    deinit {
        print("deinit DashboardVC")
    }


}
