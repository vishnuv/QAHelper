//
//  AddCommentResponse.swift
//  QAHelper
//
//  Created by Denow on 17/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper


class AddCommentResponse: Mappable {

    var commentId: String?
    var author: User?
    var updateAuthor: User?
    var body: String?
    var created: String?
    var updated: String?
    
    required init?(map: Map) {
    }

    func mapping(map: Map) {
        commentId <- map["id"]
        author <- map["author"]
        updateAuthor <- map["updateAuthor"]
        body <- map["body"]
        created <- map["created"]
        updated <- map["updated"]
    }
}
