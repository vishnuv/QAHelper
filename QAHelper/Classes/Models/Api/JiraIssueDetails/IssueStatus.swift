//
//  IssueStatus.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueStatus: NSObject, Mappable {

    var statusId: String?
    var name: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        statusId <- map["id"]
        name <- map["name"]
    }
}
