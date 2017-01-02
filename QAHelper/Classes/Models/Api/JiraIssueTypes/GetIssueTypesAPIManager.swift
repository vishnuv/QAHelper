//
//  GetIssueTypes.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 23/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class GetIssueTypesAPIManager: ApiManager {
    typealias ApiCallback = ([IssueType]?, Error?) -> Void

    class func getIssueTypes(userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issueType

        executeRequest(url, method: .get, parameters:nil, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value {
                    let issueTypes = Mapper<IssueType>().mapArray(JSONObject: json)
                    callback(issueTypes, nil)
                }

            }
        }
    }
}
