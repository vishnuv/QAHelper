//
//  IssueFields.swift
//  QAHelper
//
//  Created by Denow on 14/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueFields: NSObject, Mappable {

    var summary: String?
    var issueDescription: String?
    var type: IssueType?
    var priority: IssuePriority?
    var status: IssueStatus?
    var assignee: User?
    var creator: User?
    var issueComment: IssueComment?
    var attachments: [Attachment]?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        summary <- map["summary"]
        issueDescription <- map["description"]
        type <- map["issuetype"]
        priority <- map["priority"]
        status <- map["status"]
        assignee <- map["assignee"]
        creator <- map["creator"]
        issueComment <- map["comment"]
        attachments <- map["attachment"]
    }
}
