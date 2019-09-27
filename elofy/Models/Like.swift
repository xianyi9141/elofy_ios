//
//  Like.swift
//  elofy
//
//  Created by raptor on 25/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias Comment = (id: Int, name: String, comment: String)

struct Like {
    var id: Int = 0
    var sender: User!
    var receiver: [User] = []
    var text: String?
    var timestamp: String?
    var timeDiffInMin: Int = 0
    var comments: [Comment]?
    var commentsCnt: Int = 0
    var likesCnt: Int = 0
    var liked: Bool = false
    var expanded: Bool = false

    init(json: JSON) {
        id = json["id"].intValue
        sender = User(json: json["usuario_responsavel"])
        receiver = json["usuarios_mencionados"].arrayValue.map(User.init)
        text = json["descricao_elogio"].stringValue
        timestamp = json["data_atualizacao"].stringValue
        timeDiffInMin = json["diff"].intValue
        commentsCnt = json["total_comment"].intValue
        likesCnt = json["total_likes"].intValue
        liked = json["i_liked"].intValue == 1
    }

    let attrs: [String: [NSAttributedStringKey: Any]] = [
        "username": [
            NSAttributedStringKey.foregroundColor: UIColor.black,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ],
        "normal": [
            NSAttributedStringKey.foregroundColor: UIColor.darkGray,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)
        ],
        "mention": [
            NSAttributedStringKey.foregroundColor: UIColor.sky,
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)
        ]
    ]

    var fromTo: NSAttributedString {
        let str = NSMutableAttributedString(string: sender.name, attributes: attrs["username"])
        let to = NSAttributedString(string: " Para ", attributes: attrs["normal"])
        let comma = NSAttributedString(string: ", ", attributes: attrs["normal"])
        str.append(to)
        for i in 0..<receiver.count {
            if i > 0 {
                str.append(comma)
            }
            str.append(NSAttributedString(string: receiver[i].name, attributes: attrs["username"]))
        }
        return str
    }

    func comment(at index: Int) -> NSAttributedString? {
        guard let comments = self.comments, 0..<comments.count ~= index else { return nil }
        let str = NSMutableAttributedString(string: "\(comments[index].name) ", attributes: attrs["username"])
        let text = NSAttributedString(string: comments[index].comment, attributes: attrs["normal"])
        str.append(text)
        return str
    }
}
