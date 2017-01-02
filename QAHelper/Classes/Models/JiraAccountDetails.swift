//
//  JiraAccountDetails.swift
//  QAHelper
//
//  Created by Denow on 28/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit

private struct JiraAccount {
    static let projectKey = "QAH"
    static let username = "sarath@qburst.com"
    static let password = "qburst123"
}

class JiraAccountDetails {

    var projectKey: String
    var username: String
    var password: String

    static let sharedInstance: JiraAccountDetails = {
            let instance = JiraAccountDetails(projectKey: JiraAccount.projectKey, username: JiraAccount.username, password: JiraAccount.password)
            return instance
    }()

    init(projectKey: String, username: String, password: String) {
        self.projectKey = projectKey
        self.username = username
        self.password = password
    }
}
