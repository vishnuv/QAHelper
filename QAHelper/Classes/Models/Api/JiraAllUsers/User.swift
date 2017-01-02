//
//  User.swift
//  QAHelper
//
//  Created by Vishnu Vardhan PV on 22/11/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import Foundation
import ObjectMapper

class User: NSObject, Mappable {

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
