//
//  GetIssueStatusResponse.swift
//  QAHelper
//
//  Created by Denow on 15/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class GetIssueStatusResponse: Mappable {

    var author: User?
    var content: String?
    var created: String?
    var filename: String?
    var attachmentId: String?
    var thumbnail: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        author <- map["author"]
        content <- map["content"]
        created <- map["created"]
        filename <- map["filename"]
        attachmentId <- map["id"]
        thumbnail <- map["thumbnail"]
    }
}
