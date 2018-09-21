//
//  Models.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 20/08/2018.
//  Copyright © 2018 Mahnoor Fatima. All rights reserved.
//

import UIKit

struct ss: Codable {
}

struct BasicResponse<T: Codable>: Codable {
    var success: Bool?
    var error: String?
    var data: T?
}

struct UserData: Codable {
    static var shared: UserData?
    var userId: Int?
    var type: Int?
    var userName: String?
    var password: String?
}

struct VendorData: Codable {
    var vendorId: Int?
    var name: String?
    var address: String?
    var vatNumber: String?
    var registrationNumber: String?
    var bankName: String?
    var bankCode: String?
    var bankAccountNumber: String?
    var status: String?
    var priority: String?
    var VendorProducts: [ProductData]?
}

struct LookupData: Codable {
    var status: [StatusData]?
    var priority: [PriorityData]?
    var companyInfo: CompanyInfoData?
}


struct ProductData: Codable {
    var productId: Int?
    var minimumRetailPrice: Int?
    var maximumRetailPrice: Int?
    var markup: Int?
    var name: String?
    var description: String?
    var ProductParameter: [Int]?
    var VendorProducts: [ProductData]?
    var Product1: [ProductData]?
    var Product2: [ProductData]?
    var Estimate: [Int]?
}

struct StatusData: Codable {
    var key: Int?
    var value: String?
}

struct PriorityData: Codable {
    var key: Int?
    var value: String?
}

struct ParamsData: Codable {
    var productId: Int?
    var parameterName: String?
    var parameterValue: Int?
    var parameterUnit: Int?
    var Product: ProductData?
}

struct CompanyInfoData: Codable {
    var COMPANY_ADDRESS: String?
    var COMPANY_ACCOUNT_NUMBER: String?
    var COMPANY_BANK_NAME: String?
    var COMPANY_BANK_BRANCH_CODE: String?
    var COMPANY_INFO: String?
}

struct ProspectData: Codable {
    var prospectId: Int?
    var workAddress: String?
    var homeAddress: String?
    var status: String?
    var generalDiscount: Int?
    var prospectName: String?
    var contactNumber: String?
    var Estimate: [String]?
}