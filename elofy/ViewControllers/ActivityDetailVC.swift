//
//  ActivityDetailVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Toast_Swift
import SwiftyJSON

class ActivityDetailVC: CommonVC {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var desc: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var actioinPanel: UIStackView!

    var activity: Activity!
    var onUpdateStatus: ((_ to: ActivityStatus) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = getString(key: .avatarXS) {
            avatar.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        } else {
            avatar.image = #imageLiteral(resourceName: "avatar")
        }
        name.text = activity.title
        desc.text = activity.description
        timestamp.text = "Até: \(activity.endAt.toDate())"
    }

    @IBAction func onAction(_ sender: UIButton) {
        var percent: Int = 0
        var atraso: Int = 0

        let action = ActivityStatus(rawValue: sender.tag)!
        switch action {
        case .done: percent = 100; atraso = 0
        case .late: percent = 50; atraso = 1
        case .pending: percent = 0; atraso = 0
        case .progress: percent = 50; atraso = 0
        default: break
        }

        let params: [String: Any] = [
            "percent": percent,
            "atraso": atraso
        ]
        post(url: "/activity/\(activity.id)", params: params) { res in
            let json = JSON(res.dictionaryBody)
            self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
            // success
            if json["status"].intValue == 1 {
                self.onUpdateStatus?(action)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

}
