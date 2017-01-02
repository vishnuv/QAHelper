//
//  Avatar.swift
//  QAHelper
//
//  Created by Denow on 05/Dec/16.
//  Copyright © 2016 QBurst. All rights reserved.
//

import UIKit
import ObjectMapper

class Avatar: Mappable {
    var icon48: String?
    var icon24: String?
    var icon16: String?
    var icon32: String?

    required init?(map: Map) {
    }

    func mapping(map: Map) {
        icon48 <- map["48x48"]
        icon24 <- map["24x24"]
        icon16 <- map["16x16"]
        icon32 <- map["32x32"]
    }
}
