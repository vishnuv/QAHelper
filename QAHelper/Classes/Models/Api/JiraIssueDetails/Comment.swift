//
//  Comments.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class Comment: Mappable {

    var commentId: String?
    var body: String?
    var created: String?
    var updated: String?
    var author: User?
    var updateAuthor: User?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        commentId <- map["id"]
        body <- map["body"]
        created <- map["created"]
        updated <- map["updated"]
        author <- map["author"]
        updateAuthor <- map["id"]
    }
}
