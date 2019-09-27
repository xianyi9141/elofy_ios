//
//  GoalCell.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class GoalCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var typePanel: UIStackView!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var percentFull: UIView!
    @IBOutlet weak var percent: UIView!
    @IBOutlet weak var percentLabel: UILabel!

    var myId: Int!
    var goal: Goal! {
        didSet {
            setup()
        }
    }

    func setup() {
        if goal.user.image.isEmpty {
            avatar.image = #imageLiteral(resourceName: "avatar")
        } else {
            avatar.sd_setImage(with: URL(string: goal.user.image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        }
        title.text = goal.title
        username.setTitle(goal.user.id == myId ? "Me" : goal.user.name, for: .normal)
        typePanel.arrangedSubviews.forEach { $0.isHidden = true }
        if goal.type == .username {
            typePanel.arrangedSubviews.filter { $0.tag == 0 || $0.tag == GoalType.team.intValue }.forEach { $0.isHidden = false }
            let type = typePanel.arrangedSubviews.filter { $0.tag == GoalType.team.intValue }.first as? UIButton
            type?.setTitle(" \(goal.team?.name ?? "")", for: .normal)
            type?.setTitleColor(.sky, for: .normal)
            type?.tintColor = .sky
        } else {
            typePanel.arrangedSubviews.filter { $0.tag == 0 || $0.tag == goal.type.intValue }.forEach { $0.isHidden = false }
            if goal.type == .team {
                let type = typePanel.arrangedSubviews.filter { $0.tag == GoalType.team.intValue }.first as? UIButton
                type?.setTitle(" Grupo", for: .normal)
                type?.setTitleColor(UIColor(rgb: 0xF41488), for: .normal)
                type?.tintColor = UIColor(rgb: 0xF41488)
            }
        }
        timestamp.text = "Última atualização: \(goal.timestamp.toDate())"
        percentLabel.text = "\(Int(goal.percentage))%"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        percentFull.backgroundColor = .groupTableViewBackground
        percent.backgroundColor = goal.color.value
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)

        percentFull.backgroundColor = .groupTableViewBackground
        percent.backgroundColor = goal.color.value
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        
        percent.backgroundColor = goal.color.value
        percent.frame = CGRect(x: 0, y: 0, width: CGFloat(goal.percentage) * percentFull.bounds.width / 100, height: percentFull.bounds.height)
    }
}
