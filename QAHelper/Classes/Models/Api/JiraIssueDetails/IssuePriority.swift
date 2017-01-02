//
//  IssuePriority.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssuePriority: Mappable {

    var priorityId: String?
    var name: String?
    var iconUrl: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        priorityId <- map["id"]
        name <- map["name"]
        iconUrl <- map["iconUrl"]
    }
}
