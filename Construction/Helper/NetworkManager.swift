//
//  NetworkManager.swift
//  Construction
//
//  Created by Mirza Ahmer Baig on 02/08/2018.
//  Copyright © 2018 Mirza Ahmer Baig. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Alamofire
import SKActivityIndicatorView

class NetworkManager {
    
    static var getData:AlamofireRequestFetch = AlamofireRequestFetch(baseUrl: Helper.PinterBaseURL)
    
    static var textLabel:UILabel!
    
    // MARK: - API Calls
    
    class func fetchUpdateGenericDataFromServer<T: Codable>(urlString: String, method: HTTPMethod, headers: HTTPHeaders?, encoding: ParameterEncoding, parameters: [String: Any]?, completionHandler: @escaping (T?, String?) -> ()) {
        getData.genericRequestToServer(subUrl: urlString, method: method, headers: headers, encoding: encoding, parameters: parameters) { (data) in
            if let data = data {
                let decoder = JSONDecoder()
                //decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard let ParsedData = try? decoder.decode(T.self, from: data) else {
                    completionHandler(nil, "Unable to Parse json...")
                    return
                }
                completionHandler(ParsedData, nil)
            } else {
                completionHandler(nil, "Something went wrong. Please try again...")
            }
            
        }
    }
    
    class func uploadFileOnServer(fileURL: URL, filename: String, completionHandler: @escaping (String?) -> ()) {
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(fileURL, withName: "file", fileName: filename, mimeType: "application/pdf")
        }, to: "\(Helper.PinterBaseURL)files/upload", headers: Helper.PinterHeaders) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    debugPrint(response)
                    if let res = response.result.value as? [String:Any] {
                        if let success = res["success"] as? Int {
                            if success == 1 {
                                completionHandler(res["url"] as? String ?? "")
                            } else {
                                completionHandler(nil)
                            }
                        } else {
                            completionHandler(nil)
                        }
                    } else {
                        completionHandler(nil)
                    }
                }
            case .failure(let encodingError):
                print(encodingError)
                completionHandler(nil)
            }
        }
    }
}

