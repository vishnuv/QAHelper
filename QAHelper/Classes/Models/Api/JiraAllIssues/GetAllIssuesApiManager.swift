//
//  GetAllIssuesApiManager.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 17/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import Alamofire

class GetAllIssuesApiManager: ApiManager {
    typealias ApiCallback = (GetAllIssuesResponse?, Error?) -> Void

    class func getAllIssues(userName: String, password: String, startIndex: Int, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.allIssues

        let projectName = JiraAccountDetails.sharedInstance.projectKey
        let maxResults = 10

        let jql = "jql=project=\(projectName) AND issuetype=Bug&maxResults=\(maxResults)&startAt=\(startIndex)"
        let bugListUrl = url + jql
        let encodedUrl = bugListUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        executeRequest(encodedUrl!, parameters:nil, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value as? [String: Any] {
                    let issues: GetAllIssuesResponse? = GetAllIssuesResponse(JSON: json)
                    debugPrint(issues?.issues?[0] as Any)
                    callback(issues, nil)
                }
            }
        }
    }
}
