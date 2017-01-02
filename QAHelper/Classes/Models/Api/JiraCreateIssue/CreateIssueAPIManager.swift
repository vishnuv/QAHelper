//
//  CreateIssueAPIManager.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 18/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import Alamofire

class CreateIssueAPIManager: ApiManager {
    typealias ApiCallback = (Any?, Error?) -> Void

    class func createIssue(userName: String, password: String, issueTypeId: String?, summary: String?, description: String?, assigneeName: String?, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issue

        var project: [String: Any] = [:]
        project["id"] = "10000"

        var issuetype: [String: Any] = [:]
        issuetype["id"] = issueTypeId

        var assignee: [String: Any] = [:]
        assignee["name"] = assigneeName

        var reporter: [String: Any] = [:]
        reporter["name"] = "admin"

        var fields: [String: Any] = [:]
        fields["project"] = project
        fields["issuetype"] = issuetype
        fields["assignee"] = assignee
        fields["reporter"] = reporter
        fields["summary"] = summary
        fields["description"] = description

        var params:[String:Any] = [:]
        params["fields"] = fields

        print(fields)

        executeRequest(url, method: .post, parameters:params, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value {
                    callback(json, nil)
                }
            }
        }
    }
}
