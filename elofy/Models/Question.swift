//
//  Question.swift
//  elofy
//
//  Created by raptor on 22/03/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

enum QuestionType: String {
    case text = "q"
    case star = "e"
    case heart = "c"
    case agree = "f"
    case multiple = "o"
}

struct Question {
    var id: Int = 0
    var queryId: Int = 0
    var question: String?
    var type: QuestionType?
    var escala: Int = 5
    var options: [(id: Int, answer: String, percentage: Float)] = []

    init(json: JSON) {
        id = json["id_questionario"].intValue
        queryId = json["id_pergunta"].intValue
        question = json["question"].string
        type = QuestionType(rawValue: json["type"].stringValue)
        escala = json["escala"].intValue
        options = json["options"].arrayValue.map { (id: $0["id"].intValue, answer: $0["answer"].stringValue, percentage: $0["percentage"].floatValue) }
    }
}
