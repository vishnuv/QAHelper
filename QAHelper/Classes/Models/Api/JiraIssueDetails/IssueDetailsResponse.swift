//
//  IssueDetailsResponse.swift
//  QAHelper
//
//  Created by Denow on 14/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueDetailsResponse: NSObject, Mappable {

    var issueId: String?
    var key: String?
    var fields: IssueFields?

    override init() {
        
    }

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        issueId <- map["id"]
        key <- map["key"]
        fields <- map["fields"]
    }
}
