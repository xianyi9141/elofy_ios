//
//  Activity.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ActivityStatus: Int {
    case pending, done, late, progress, none
}

struct Activity {
    var id: Int = 0
    var title: String?
    var description: String?
    var percentage: Float = 0
    var atraso: Int = 0
    var startAt: String = ""
    var endAt: String = ""
    var user: User!
    var status: ActivityStatus! {
        if 0..<50 ~= percentage, atraso == 0 { return .pending }
        else if 50..<100 ~= percentage, atraso == 0 { return .progress }
        else if 100 == percentage, atraso == 0 { return .done }
        else if percentage <= 50, atraso == 1 { return .late }
        else { return .none }
    }

    init(json: JSON) {
        id = json["id"].intValue
        title = json["title"].string
        description = json["description"].string
        percentage = json["percentage"].floatValue
        atraso = json["atraso"].intValue
        startAt = json["init"].stringValue
        endAt = json["fim"].string ?? json["end"].stringValue
        user = User(json: json["user"])
    }
}
