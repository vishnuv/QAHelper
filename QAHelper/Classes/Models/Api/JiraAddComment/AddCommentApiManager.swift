//
//  AddCommentApiManager.swift
//  QAHelper
//
//  Created by Denow on 16/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire

struct AddCommentConstants {
    static let body = "body"
}

class AddCommentApiManager: ApiManager {

    typealias ApiCallback = (AddCommentResponse?, Error?) -> Void

    class func addComment(comment: String, ToIssue issueId: String, userName: String, password: String, callback: @escaping ApiCallback) {
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }

        let url = Constants.Api.jiraUrl + Constants.ApiNames.issue + "/" + issueId + "/" + Constants.ApiNames.comment
        debugPrint("url: \(url)")

        var params: [String: Any] = [:]
        params[AddCommentConstants.body] = comment

        executeRequest(url, method: .post, parameters: params, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value as? [String: Any] {
                    let details: AddCommentResponse? = AddCommentResponse(JSON: json)
                    callback(details, nil)
                }
            }
        }
    }
}
