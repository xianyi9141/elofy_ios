//
//  User.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct User {
    var id: Int = 0
    var name: String = ""
    var campanyId: Int = 0
    var image: String = ""
    var image50px: String = ""
    var image150px: String = ""

    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
        campanyId = json["id_empresa"].intValue
        image = json["image"].string ?? json["orignal_image"].string ?? ""
        image50px = json["xs_image"].string ?? ""
        image150px = json["md_image"].string ?? ""
    }
}
