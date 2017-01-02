//
//  AddAttachmentApiManger.swift
//  QAHelper
//
//  Created by Denow on 22/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import Alamofire

struct AddAttachmentApiConstants {
    static let atlassianToken = "X-Atlassian-Token"
    static let noCheck = "no-check"
    static let file = "file"
}

class AddAttachmentApiManger: ApiManager {

    typealias ApiCallbackAttachment = (AddAttachmentResponse?, Error?) -> Void
    typealias ApiCallbackComment = (AddCommentResponse?, Error?) -> Void

    class func addAttachmentWithoutComment(_ fileUrl: URL, issueId: String, userName: String, password: String, callback: @escaping ApiCallbackAttachment) {

        let fromUrls: [URL] = [fileUrl]
        let names = [AddAttachmentApiConstants.file];
        let toUrl = Constants.Api.jiraUrl + Constants.ApiNames.issue + "/" + issueId + "/" + Constants.ApiNames.attachments
        let params: [String: Any] = [:]

        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: userName, password: password) {
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        headers[AddAttachmentApiConstants.atlassianToken] = AddAttachmentApiConstants.noCheck

        uploadFileFromUrl(fromUrls, names: names, toUrl: toUrl, method: .post, parameters: params, headers: headers) { (response, error) in
            if let error = error {
                callback(nil, error)
            } else {
                if let json = response?.result.value as? [Any] {
                    if let dict = json.first as? [String: Any] {
                        debugPrint("dict: \(dict)")
                        let details: AddAttachmentResponse? = AddAttachmentResponse(JSON: dict)
                        callback(details, nil)
                    }
                }
            }
        }
    }

    class func addAttachment(_ fileUrl: URL, comment: String = "", issueId: String, userName: String, password: String, callback: @escaping ApiCallbackComment) {

        addAttachmentWithoutComment(fileUrl, issueId: issueId, userName: userName, password: password) { (response, error) in

            if let error = error {
                debugPrint("Error: \(error)")
                callback(nil, error)
            } else {
                if let imgName = response?.filename {
                    let updatedComment = "!" + imgName + "|thumbnail!" + "\n" + comment
                    AddCommentApiManager.addComment(comment: updatedComment, ToIssue: issueId, userName: userName, password: password, callback: { (response, error) in
                        if let error = error {
                            debugPrint("Error: \(error)")
                            callback(response, error)
                        } else {
                            debugPrint("Comment succesfully added")
                            callback(response, nil)
                        }
                    })
                }
            }
        }
    }
}
