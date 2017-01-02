//
//  Attachment.swift
//  QAHelper
//
//  Created by Denow on 01/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class Attachment: Mappable {

    var attachmentId: String?
    var filename: String?
    var author: User?
    var created: String?
    var content: String?
    var thumbnail: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        attachmentId <- map["id"]
        filename <- map["filename"]
        author <- map["author"]
        created <- map["created"]
        content <- map["content"]
        thumbnail <- map["thumbnail"]
    }
}
