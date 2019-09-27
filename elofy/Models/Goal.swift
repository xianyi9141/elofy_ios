//
//  Goal.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

enum GoalStatus: Int {
    case pending, done, progress, close, none
}

enum GoalType: String {
    case shared = "c"
    case individual = "i"
    case team = "t"
    case username = ""

    var intValue: Int {
        switch self {
        case .shared: return 1
        case .individual: return 2
        case .team: return 3
        default: return 999
        }
    }
}

enum GoalColor: Int {
    case none, ontrack, attention, delayed
    var value: UIColor {
        switch self {
        case .none: return UIColor.sky
        case .ontrack: return UIColor(rgb: 0x33a9f4)
        case .attention: return UIColor(rgb: 0xeede46)
        case .delayed: return UIColor(rgb: 0xe06469)
        }
    }
}

struct Goal {
    var id: Int = 0
    var parentId: Int = 0
    var title: String?
    var description: String?
    var status: GoalStatus = .none
    var type: GoalType = .username
    var color: GoalColor = .none
    var percentage: Float = 0
    var user: User!
    var team: (id: Int, name: String)?
    var cycles: [(id: Int, name: String, startAt: String, endAt: String)] = []
    var timestamp: String = ""
    var year: String?
    var resultKeys: [ResultKey]?
    var raw: String = ""

    init(json: JSON) {
        id = json["id"].intValue
        parentId = json["parent_id"].intValue
        title = json["title"].stringValue
        description = json["description"].stringValue
        status = GoalStatus(rawValue: json["status"].intValue) ?? .none
        type = GoalType(rawValue: json["type"].stringValue) ?? .username
        color = GoalColor(rawValue: json["color"].intValue) ?? .none
        percentage = json["percentage"].floatValue
        user = User(json: json["user"])
        team = json["team"].exists() ? (id: json["team"]["id"].intValue, name: json["team"]["name"].stringValue) : nil
        cycles = json["cycles"].arrayValue.map { (
            id: $0["id"].intValue,
            name: $0["name"].stringValue,
            startAt: $0["inicio_vigencia"].stringValue,
            endAt: $0["fim_vigencia"].stringValue
            ) }
        timestamp = json["end"].stringValue
        year = json["year"].string
        resultKeys = json["keys"].array?.map(ResultKey.init)
        // only store raw for OKR
        if json["keys"].exists() {
            raw = json.rawString()?.lowercased() ?? ""
        }
    }
}
