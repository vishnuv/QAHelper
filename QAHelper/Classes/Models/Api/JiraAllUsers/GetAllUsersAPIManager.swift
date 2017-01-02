//
//  GetAllUsersAPIManager.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 21/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class GetAllUsersAPIManager: ApiManager {
    typealias ApiCallback = ([User]?, Error?) -> Void

    class func getAllUsers(userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let projectName = JiraAccountDetails.sharedInstance.projectKey
        let url = Constants.Api.jiraUrl + Constants.ApiNames.allUsers + projectName

        executeRequest(url, method: .get, parameters:nil, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value {
                    let users = Mapper<User>().mapArray(JSONObject: json)
                    callback(users, nil)
                }

            }
        }
    }
}
