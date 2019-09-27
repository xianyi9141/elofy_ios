//
//  UpdateCell.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class UpdateCell: UITableViewCell {
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var timediff: UILabel!
    @IBOutlet weak var top: UIView!
    @IBOutlet weak var bottom: UIView!
    @IBOutlet weak var middle: UIView!

    let colors: [UIColor] = [
        UIColor(rgb: 0xEC000C),
        UIColor(rgb: 0xC8FAC2),
        UIColor(rgb: 0xB2E7FF)
    ]

    var update: Update! {
        didSet {
            setup()
        }
    }

    func setup() {
        timestamp.text = update.timestamp
        content.text = update.content
        timediff.text = CommonVC.periodInMinutesToString(update.timeDiffInMin)
        middle.backgroundColor = colors[update.type]
    }
}
