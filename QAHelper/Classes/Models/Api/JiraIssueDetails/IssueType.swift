//
//  IssueType.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueType: NSObject, Mappable {

    var issueid: String?
    var issueName: String?
    var iconUrl: String?
    var subtask: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        issueid <- map["id"]
        issueName <- map["name"]
        iconUrl <- map["iconUrl"]
        subtask <- map["subtask"]
    }

}
