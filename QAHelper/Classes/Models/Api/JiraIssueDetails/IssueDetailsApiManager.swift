//
//  IssueDetailsApiManager.swift
//  QAHelper
//
//  Created by Denow on 14/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper


class IssueDetailsApiManager: ApiManager {

    typealias ApiCallback = (IssueDetailsResponse?, Error?) -> Void

    class func getIssueDetails(issueId: String, userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issue + "/" + issueId

        executeRequest(url, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value as? [String: Any] {
                    let details: IssueDetailsResponse? = IssueDetailsResponse(JSON: json)
                    callback(details, nil)
                }
            }
        }
    }
}
