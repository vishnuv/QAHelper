//
//  GetIssueStatus.swift
//  QAHelper
//
//  Created by Denow on 15/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire


class GetStatusTypesApiManager: ApiManager {

    typealias ApiCallback = (GetIssueStatusResponse?, Error?) -> Void

    class func getStatusTypesForProject(projectId: String, userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.project + "/" + projectId + "/" + Constants.ApiNames.statusTypes
        debugPrint("url: \(url)")

        executeRequest(url, method: .get, parameters: nil, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value as? [String: Any] {
                    let details: GetIssueStatusResponse? = GetIssueStatusResponse(JSON: json)
                    callback(details, nil)
                }
            }
        }
    }
}
