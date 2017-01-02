//
//  Creator.swift
//  QAHelper
//
//  Created by Denow on 15/Nov/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class Creator: Mappable {

    var name: String?
    var displayName: String?
    var emailAddress: String?
    var avatarUrls: Avatar?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        name <- map["name"]
        displayName <- map["displayName"]
        emailAddress <- map["emailAddress"]
        avatarUrls <- map["avatarUrls"]
    }
}
