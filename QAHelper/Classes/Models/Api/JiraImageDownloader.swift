//
//  JiraImageDownloader.swift
//  QAHelper
//
//  Created by Sarath Vijay on 06/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire

class JiraImageDownloader {
    
    typealias ImageDownloderCallback = (UIImage?, Error?) -> Void
    
    class func downloadImage(url : String, callback: @escaping ImageDownloderCallback) {
        
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: JiraAccountDetails.sharedInstance.username, password: JiraAccountDetails.sharedInstance.password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        let urlConvertible = URL(string: url)

        Alamofire.request(urlConvertible!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseData { (response) in
            if let data = response.result.value {
                let image = UIImage(data: data)
                callback(image, nil)
            } else {
                callback(nil, response.result.error)
            }
        }
    }

}
