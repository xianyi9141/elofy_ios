//
//  ActivityCell.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SDWebImage

class ActivityCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var buttonStatus: UIStackView!

    var onDelete: (() -> Void)?
    var activity: Activity! {
        didSet {
            setup()
        }
    }

    func setup() {
        title.text = activity.title
        desc.text = activity.description
        timestamp.text = "Até: \(activity.endAt.toDate())"

        buttonStatus.arrangedSubviews.forEach { $0.isHidden = true }
        buttonStatus.arrangedSubviews.filter { $0.tag == activity.status.rawValue }.forEach { $0.isHidden = false }
    }

    @IBAction func onDeleteAction(_ sender: Any) {
        onDelete?()
    }
}
