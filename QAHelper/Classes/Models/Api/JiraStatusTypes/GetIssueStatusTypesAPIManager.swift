//
//  GetStatusTypesAPIManager.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 19/12/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class GetIssueStatusTypesAPIManager: ApiManager {
    typealias ApiCallback = ([IssueStatus]?, Error?) -> Void

    class func getIssueStatusTypes(userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issueStatus

        executeRequest(url, method: .get, parameters:nil, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value {
                    let issueStatuses = Mapper<IssueStatus>().mapArray(JSONObject: json)
                    callback(issueStatuses, nil)
                }

            }
        }
    }
}
