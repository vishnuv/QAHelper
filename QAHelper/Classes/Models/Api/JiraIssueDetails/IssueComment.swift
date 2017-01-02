//
//  IssueComment.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class IssueComment: Mappable {

    var maxResults: Int?
    var total: Int?
    var startAt: Int?
    var comments: [Comment]?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        maxResults <- map["maxResults"]
        total <- map["total"]
        startAt <- map["startAt"]
        comments <- map["comments"]
    }
}
