//
//  GetAllIssuesResponse.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 17/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import ObjectMapper

class GetAllIssuesResponse: Mappable {

    var startAt: Int?
    var maxResults: Int?
    var total: Int?
    var issues: [IssueDetailsResponse]?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        startAt <- map["startAt"]
        maxResults <- map["maxResults"]
        total <- map["total"]
        issues <- map["issues"]
    }
}
