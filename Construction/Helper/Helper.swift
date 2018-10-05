
//
//  Helper.swift
//  Construction
//
//  Created by Mac on 22/05/2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit


class Helper {
    static let NoImageURL = "http://newhorizonindia.edu/college_edu/wp-content/uploads/2016/07/member_default_img-200x200.png"
    static let GetProductImageURL = "http://nordtex.no.ws1.my-hosting-panel.com/Images/Products/"
    
    
    static let PinterBaseURL: String = "http://nordtex.no.ws1.my-hosting-panel.com/api/"
    
    
    
    
    
    static let UserInfoDefaultsID = "UserInfoDefaults"
    static let AccessTokenDefaultsID = "AccessTokenDefaults"
    
    
    static var PinterHeaders: [String: String] {
        return ["x-access-token": Helper.accessToken ]
    }
    
    //URLs
    
    static let GetVendorsURL = "vendor"
    static let GetProductsURL = "product"
    static let GetSettingsURL = "lookup"
    static let GetProductParamsURL = "ProductParameter"
    static let GetGroupedProductsURL = "GroupedProducts"
    static let GetProspectsURL = "Prospect"
    static let GetProductVendorURL = "ProductVendors"
    static let GetVendorProductURL = "VendorProducts"
    static let GetVendorDetailsURL = "Vendor"
    static let GetProductDetailsURL = "Product"
    static let GETNotesURL = "Notes"
    static let GetEstimatesURL = "Estimate"
    
    static let PostUsersURL = "users"
    static let PostCompanyInfoURL = "company"
    static let PostVendorURL = "vendor"
    static let PostProductURL = "product"
    static let PostProspectURL = "Prospect"
    static let PostVendorProductURL = "VendorProducts"
    static let PostProductParamsURL = "ProductParameter"
    
    
    static let PostImageURL = "Images"
    
    
    static var accessToken = ""
    
    static let PlacesMapKey = "AIzaSyB3n_BPiKhOt74bG6yXywTL1h_XlJ_XmQQ"
    
    
    
    // MARK: - collection&table ViewResuableID
    static let MoreCellID = "More Cell"
    static let UserInfoCellID = "UserInfo Cell"
    static let VendorsCellID = "Vendors Cell"
    static let VendorDetailsCellID = "Vendor Details Cell"
    static let ProductsCellID = "Products Cell"
    static  let EditProductSegueID = "Edit Product"
    static let ProductDetailsCellID = "Product Details Cell"
    static let SettingsCellID = "Settings Cell"
    static let ProspectsCellID = "Prospects Cell"
    static let ProspectDetailsCellID = "Prospect Details Cell"
    static let ProductVendorsCellID = "Product Vendors Cell"
    static let VendorProductsCellID = "Vendor Products Cell"
    static let GroupedProductsCellID = "Grouped Products Cell"
    static let EstimatesCellID = "Estimates Cell"
    static let AddEstimatesCellID = "Add Estimate Cell"
    static let AddProductsCellID = "Add Product Cell"
    static let EstimateTextFieldCellID = "Estimate TextField Cell"
    
    static let SearchCellID = "searchCell"
    
    
    // MARK: - SegueID
    static  let VerifyFirstSegueID = "verifyFirst"
    static  let loginSegueID = "Login"
    static  let forgotSegueID = "Forgot"
    static  let LoggedInSegueID = "LoggedIn"
    static  let signupSegueID = "Signup"
    static  let LogoutSegueID = "Logout"
    static  let ProductsSegueID = "Products"
    static  let VendorsSegueID = "Vendors"
    static  let SettingsSegueID = "Settings"
    static  let VendorDetailsSegueID = "Vendor Details"
    static  let ProductDetailsSegueID = "Product Details"
    static  let AddProductSegueID = "Add Product"
    static  let AddVendorSegueID = "Add Vendor"
    static  let UpdateSettingsSegueID = "Update Settings"
    static  let AddParametersSegueID = "Add Parameters"
    static  let EditVendorSegueID = "Edit Vendor"
    static  let ProspectDetailsSegueID = "Prospect Details"
    static  let AddProspectSegueID = "Add Prospect"
    static  let ProductVendorsSegueID = "Product Vendors"
    static  let ShowVendorsSegueID = "Show Vendors"
    static  let AddProductVendorSegueID = "Add Product Vendor"
    static  let VendorProductsSegueID = "Vendor Products"
    static  let AddVendorProductSegueID = "Add Vendor Product"
    static  let AddProductParametersSegueID = "Add Parameters"
    static  let AddGroupedProductsSegueID = "Grouped Products"
    static  let AddEstimateSegueID = "Add Estimate"
    static  let AddProductsSegueID = "Add Products"
    static  let AddProspectsSegueID = "Add Prospects"
    
    
    // MARK: - Defaults ID
    static let rideDataDefaultsID = "rideData"
    static let UserProfileDefaultsID = "UserProfileDefaults"
    static let isLoggedInDefaultID = "isLoggedIn"
    static let fcmTokenDefaultsID = "FCM Token"
}

