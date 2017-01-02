//
//  ApiManager.swift
//  QAHelper
//
//  Created by Denow on 11/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import KRProgressHUD

class ApiManager {

    typealias ResultCallback = (DataResponse<Any>?, Error?) -> Void

//    Automatic Validation
//    Automatically validates status code within 200...299 range, and that the Content-Type header of the response matches the Accept header of the request, if one is provided.
    class func executeRequest(_ url: URLConvertible,
                              method: HTTPMethod = .get,
                              parameters: Parameters? = nil,
                              headers: HTTPHeaders? = nil,
                              onCompletion: @escaping ResultCallback) {
        KRProgressHUD.set(style:.black)
        KRProgressHUD.show()
        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).validate(statusCode: 200...299).responseJSON { response in

            debugPrint(response.request as Any)  // original URL request
            debugPrint(response.response as Any) // HTTP URL response
            debugPrint(response.data as Any)     // server data
            debugPrint(response.result as Any)   // result of response serialization


            debugPrint("StatusCode: \(response.response?.statusCode)")
            debugPrint("Error: \(response.result.error)")
            debugPrint("localizedDescription: \(response.result.error?.localizedDescription)")
            debugPrint("Description: \(response.result.error)")

                switch response.result {
                case .success(let value):
                    debugPrint("Success Value: \(value)")
                    onCompletion(response, nil)
                    break
                case .failure(let nsError):
                    debugPrint("Failure Value: \(nsError)")
                    onCompletion(response, nsError)
                    break
                }
            KRProgressHUD.dismiss()
        }
    }

    class func uploadFileFromUrl(_ fromUrls: [URL],
                                 names: [String],
                                 toUrl: URLConvertible,
                                 method: HTTPMethod = .get,
                                 parameters: Parameters? = nil,
                                 headers: HTTPHeaders? = nil,
                                 onCompletion: @escaping ResultCallback) {

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                for(item1, item2) in zip(fromUrls, names){
                    debugPrint("item1: \(item1)")
                    debugPrint("item2: \(item2)")
                    multipartFormData.append(item1, withName: item2)
                }
            },
            to: toUrl,
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response.result.value as Any)
                        if response.result.isSuccess {
                            onCompletion(response, nil)
                        } else {
                            if let error = response.result.error {
                                onCompletion(nil, error)
                            }
                        }

                    }
                case .failure(let error):
                    debugPrint(error)
                    onCompletion(nil, error)
                }
            }
        )
    }
}

//Samples
extension ApiManager {
    
    // Sample request
    class func makeReq() {
        Alamofire.request("https://httpbin.org/get").responseJSON { response in
            debugPrint(response.request as Any)  // original URL request
            debugPrint(response.response as Any) // HTTP URL response
            debugPrint(response.data as Any)     // server data
            debugPrint(response.result as Any)   // result of response serialization

            if response.result.isSuccess {
                debugPrint("Success")
            } else {
                debugPrint("Failed")
                debugPrint("StatusCode: \(response.response?.statusCode)")
                debugPrint("Error: \(response.result.error)")
                debugPrint("localizedDescription: \(response.result.error?.localizedDescription)")
                debugPrint("Description: \(response.result.error)")
            }

            if let JSON = response.result.value {
                debugPrint("JSON: \(JSON)")
            }
        }
    }

    class func executeRequest2(_ url: URLConvertible,
                               method: HTTPMethod = .get,
                               parameters: Parameters? = nil,
                               headers: HTTPHeaders? = nil,
                               onCompletion: @escaping ResultCallback) {
        Alamofire.request(url, method: method, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            if response.result.isSuccess {
                debugPrint("Success")
                onCompletion(response, nil)
            } else {
                debugPrint("Failed")
                debugPrint("StatusCode: \(response.response?.statusCode)")
                debugPrint("Error: \(response.result.error)")
                debugPrint("localizedDescription: \(response.result.error?.localizedDescription)")
                debugPrint("Description: \(response.result.error)")
                onCompletion(response, response.result.error)
            }
        }
    }
}
