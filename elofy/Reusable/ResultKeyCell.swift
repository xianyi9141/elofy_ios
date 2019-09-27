//
//  ResultKeyCell.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class ResultKeyCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var percentFull: UIView!
    @IBOutlet weak var percenetLabel: UILabel!
    @IBOutlet weak var percent: UIView!
    @IBOutlet weak var activitiesPanel: UIStackView!
    @IBOutlet weak var btnDetail: UIButton!
    
    var beginUpdate: (() -> Void)?
    var endUpdate: (() -> Void)?
    var onSettingResultKey: (() -> Void)?
    var onActivityClicked: ((_ activity: Activity) -> Void)?
    var resultKey: ResultKey!
    var userId: Int = 0

    func update() {
        beginUpdate?()
        if resultKey.user.image.isEmpty {
            avatar.image = #imageLiteral(resourceName: "avatar")
        } else {
            avatar.sd_setImage(with: URL(string: resultKey.user.image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        }
        title.text = resultKey.title
        username.text = resultKey.user.name
        percent.constraint("width")?.constant = CGFloat(resultKey.percentage) * percentFull.bounds.width / 100
        percenetLabel.text = "\(Int(resultKey.percentage))%"
        btnDetail.isHidden = resultKey.user.id != userId
        activitiesPanel.arrangedSubviews.filter { $0 is UIStackView }.forEach { $0.removeFromSuperview() }
        resultKey.activities.forEach { activity in
            let str = NSMutableAttributedString(
                string: activity.title ?? "",
                attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .medium)]
            )
            str.append(
                NSAttributedString(
                    string: "\n\(activity.user.name)\(activity.user.id == userId ? " (Me)" : "")",
                    attributes: [
                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14),
                        NSAttributedStringKey.foregroundColor: UIColor.sky
                    ]
                )
            )
            str.append(
                NSAttributedString(
                    string: "\n\(activity.startAt.toDate()) - \(activity.endAt.toDate())",
                    attributes: [
                        NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14, weight: .light),
                        NSAttributedStringKey.foregroundColor: UIColor.lightGray
                    ]
                )
            )
            let content = UILabel()
            content.attributedText = str
            content.numberOfLines = 0
            content.font = UIFont.systemFont(ofSize: 14, weight: .medium)

            let percent = UILabel()
            percent.text = "\(Int(activity.percentage))%"
            percent.numberOfLines = 1
            percent.textColor = .lightGray
            percent.font = UIFont.systemFont(ofSize: 14)
            percent.textAlignment = .right
            percent.widthAnchor.constraint(equalToConstant: 40).isActive = true

            let stackView = UIStackView(arrangedSubviews: [content, percent])
            stackView.axis = .horizontal
            stackView.alignment = .top
            stackView.distribution = .fill
            stackView.spacing = 0
            stackView.tag = activity.id
            stackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ResultKeyCell.onActivityTapped(_:))))

            self.activitiesPanel.addArrangedSubview(stackView)
        }
        activitiesPanel.isHidden = !resultKey.expanded
        endUpdate?()
    }

    @IBAction func onSettingAction(_ sender: UIButton) {
        onSettingResultKey?()
    }

    @objc func onActivityTapped(_ sender: UITapGestureRecognizer) {
        guard let activityId = sender.view?.tag else { return }
        onActivityClicked?(resultKey.activities.filter { $0.id == activityId }.first!)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        percentFull.backgroundColor = .groupTableViewBackground
        percent.backgroundColor = .grass
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        percentFull.backgroundColor = .groupTableViewBackground
        percent.backgroundColor = .grass
    }
}
