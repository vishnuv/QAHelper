//
//  EditIssueApiManager.swift
//  QAHelper
//
//  Created by Denow on 30/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire

private struct EditIssueConstants {
    static let assignee = "assignee"
    static let name = "name"
    static let fields = "fields"
    static let successStatusCode: Int = 204
}

class EditIssueApiManager: ApiManager {

    typealias ApiCallback = (EditIssueResponse?, Error?) -> Void

    class func updateAssignee(newAssigneeName: String, ToIssue issueId: String, userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issue + "/" + issueId
        debugPrint("url: \(url)")

        var name: [String: Any] = [:]
        name[EditIssueConstants.name] = newAssigneeName

        var fields: [String: Any] = [:]
        fields[EditIssueConstants.assignee] = name

        var params: [String: Any] = [:]
        params[EditIssueConstants.fields] = fields


        executeRequest(url, method: .put, parameters: params, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value {
                    debugPrint("json: \(json)")
                    let editResp: EditIssueResponse = EditIssueResponse()
                    if response?.response?.statusCode == EditIssueConstants.successStatusCode {
                        editResp.isSuccess = true
                    } else {
                        editResp.isSuccess = false
                    }
                    callback(editResp, nil)
                }
            }
        }
    }
}
