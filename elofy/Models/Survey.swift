//
//  Survey.swift
//  elofy
//
//  Created by raptor on 22/03/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Survey {
    var id: Int = 0
    var name: String?
    var questionId: Int = 0
    var isActive: Bool = false
    var userName: String?
    var isAnswered: Bool = false
    var count: Int = 0
    var timestamp: String?

    init(json: JSON) {
        id = json["id_pesquisa"].intValue
        name = json["nome_pesquisa"].string
        questionId = json["id_questionario"].intValue
        isActive = json["ativo"].intValue == 1
        userName = json["nome_usuario"].string
        isAnswered = json["respondida"].intValue == 1
        count = json["surveys"].intValue
        timestamp = json["data_atualizacao"].string
    }
}
