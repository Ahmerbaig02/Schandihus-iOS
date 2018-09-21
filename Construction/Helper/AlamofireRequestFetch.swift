
//
//  AlamofireRequestFetch.swift
//  Construction
//
//  Created by Mac on 07/01/2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Alamofire


class AlamofireRequestFetch {
    
    var baseUrl:String!
    
    var getRequest:Alamofire.Request!
    
    init(baseUrl:String) {
        
        self.baseUrl = baseUrl
        
    }
    
    func genericRequestToServer(subUrl:String, method: HTTPMethod, headers: HTTPHeaders?, encoding: ParameterEncoding, parameters: [String:Any]?, completionHandler: @escaping (Data?) -> ()) {
        
        if let url = (self.baseUrl+subUrl).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            print(url)
            getRequest = Alamofire.request(url , method: method, parameters: parameters, encoding: encoding, headers: headers).validate(contentType: ["application/json", "application/x-www-form-urlencoded"]).responseData(completionHandler: { (data) in
                completionHandler(data.data)
            })
        } else {
            completionHandler(nil)
        }

    }
    
    
    deinit {
        
        if getRequest != nil {
            getRequest.cancel()
        }
        print("Alamofire Request Fetch deinit")
    }
    
}
