//
//  MentionUser.swift
//  elofy
//
//  Created by raptor on 26/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import Hakawai
import SwiftyJSON

class MentionUser: NSObject {
    var id: Int = 0
    var name: String = ""

    init(json: JSON) {
        id = json["id"].intValue
        name = json["name"].stringValue
    }
}

extension MentionUser: HKWMentionsEntityProtocol {
    func entityId() -> String! {
        return id.description
    }

    func entityName() -> String! {
        return name
    }

    func entityMetadata() -> [AnyHashable: Any]! {
        return [:]
    }
}
