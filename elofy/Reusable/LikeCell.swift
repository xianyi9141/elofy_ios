//
//  LikeCell.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import LGButton

class LikeCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var commenters: UILabel!
    @IBOutlet weak var timeDiff: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var textbox: UITextField!
    @IBOutlet weak var btnComments: LGButton!
    @IBOutlet weak var btnLikes: UIButton!
    @IBOutlet weak var commentPanel: UIStackView!

    var beginUpdate: (() -> Void)?
    var endUpdate: (() -> Void)?
    var onLike: (() -> Void)?
    var onRequestComments: (() -> Void)?
    var onAddComment: ((_ text: String?) -> Void)?
    var like: Like! {
        didSet { textbox.text = nil }
    }

    func update() {
        if !like.sender.image.isEmpty {
            avatar.sd_setImage(with: URL(string: like.sender.image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        } else {
            avatar.image = #imageLiteral(resourceName: "avatar")
        }
        commenters.attributedText = like.fromTo
        timeDiff.text = CommonVC.periodInMinutesToString(like.timeDiffInMin)
        comment.text = like.text

        btnComments.titleString = " \(like.commentsCnt) Comentários"
        btnComments.isUserInteractionEnabled = like.commentsCnt > 0

        btnLikes.setTitle(" \(like.likesCnt) Curtir", for: .normal)
        btnLikes.isEnabled = !like.liked

        if like.commentsCnt == 0 {
            btnComments.rightImageSrc = nil
        } else if like.expanded {
            btnComments.rightImageSrc = #imageLiteral(resourceName: "arrow_up")
        } else {
            btnComments.rightImageSrc = #imageLiteral(resourceName: "arrow_down")
        }

        if like.expanded { expand() }
        else { collapse() }
    }

    func expand() {
        guard let comments = like.comments else { return }

        beginUpdate?()
        self.commentPanel.arrangedSubviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
        for index in 0..<comments.count {
            let label = UILabel()
            label.attributedText = self.like.comment(at: comments.count - index - 1)
            label.numberOfLines = 0
            self.commentPanel.insertArrangedSubview(label, at: 0)
        }
        self.btnComments.rightImageSrc = #imageLiteral(resourceName: "arrow_up")
        like.expanded = true
        endUpdate?()
    }

    func collapse() {
        beginUpdate?()
        self.commentPanel.arrangedSubviews.filter { $0 is UILabel }.forEach { $0.removeFromSuperview() }
        self.btnComments.rightImageSrc = #imageLiteral(resourceName: "arrow_down")
        like.expanded = false
        endUpdate?()
    }

    @IBAction func onSendAction(_ sender: Any) {
        onAddComment?(textbox.text)
    }

    @IBAction func onToggleComment(_ sender: Any) {
        if like.expanded {
            collapse()
        } else if let _ = like.comments {
            expand()
        } else {
            onRequestComments?()
        }
    }

    @IBAction func onLikeAction(_ sender: Any) {
        onLike?()
    }
}
