//
//  Update.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Update {
    var id: Int = 0
    var type: Int = 2 // 0: warning, 1: success, 2: info
    var content: String?
    var timestamp: String?
    var timeDiffInMin: Int = 0

    init(json: JSON) {
        id = json["id"].intValue
        type = json["type"].intValue
        content = json["event"].string
        timestamp = json["date"].string?.toDate()
        timeDiffInMin = json["diff"].intValue
    }


}
