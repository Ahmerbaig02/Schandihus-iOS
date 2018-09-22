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
    
    class func uploadFileOnServer<T: Codable>(urlString: String, fileURL: URL, filename: String, withName: String, completionHandler: @escaping (T?, String?) -> ()) {
        Alamofire.upload(multipartFormData: { (formData) in
            formData.append(fileURL, withName: withName, fileName: filename, mimeType: "application/jpeg")
        }, to: urlString, headers: nil) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseData(completionHandler: { (data) in
                    if let data = data.data {
                        let decoder = JSONDecoder()
                        //decoder.keyDecodingStrategy = .convertFromSnakeCase
                        guard let ParsedData = try? decoder.decode(T.self, from: data) else {
                            completionHandler(nil, "Unable to Parse json...")
                            return
                        }
                        completionHandler(ParsedData, nil)
                    } else {
                        
                    }
                })
            case .failure(let encodingError):
                print(encodingError)
                completionHandler(nil, encodingError.localizedDescription)
            }
        }
    }
}

