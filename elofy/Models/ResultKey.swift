//
//  ResultKey.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct ResultKey {
    var id: Int = 0
    var title: String?
    var user: User!
    var from: Float = 0
    var to: Float = 0
    var actual: Float = 0
    var percentage: Float = 0
    var unit: String = ""
    var timestamp: String = ""
    var activities: [Activity] = []
    var expanded: Bool = false

    init(json: JSON) {
        id = json["id"].intValue
        title = json["title"].stringValue
        user = User(json: json["user"])
        from = json["de"].floatValue
        to = json["para"].floatValue
        actual = json["atual"].floatValue
        percentage = json["percentage"].floatValue
        timestamp = json["last_date"].stringValue
        unit = json["measurement"].stringValue
        activities = json["activities"].arrayValue.map(Activity.init)
        expanded = !activities.isEmpty
    }
}
