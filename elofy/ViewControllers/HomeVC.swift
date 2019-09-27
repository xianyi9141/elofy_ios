//
//  MainVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON

class HomeVC: CommonVC {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var hello: UILabel!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = getString(key: .avatarMD) ?? getString(key: .avatarOriginal) {
            avatar.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        } else {
            avatar.image = #imageLiteral(resourceName: "avatar")
        }
        hello.text = "Olá!, \(getString(key: .name) ?? "lá")!"

        // device token
        if let token = getString(key: . deviceToken) {
            post(url: "/devicetoken", params: ["token": token], indicator: false) { res in
                let json = JSON(res.dictionaryBody)
                print(json["message"].stringValue)
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatar.layer.cornerRadius = avatar.bounds.height / 2
    }

    @IBAction func onSurveysAction(_ sender: UITapGestureRecognizer) {
        self.view.makeToast("Pesquisas em breve...", duration: 2, position: .top)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? TabVC, let gesture = sender as? UITapGestureRecognizer, let tag = gesture.view?.tag, let page = TabPage(rawValue: tag) {
            vc.page = page
        }
    }
}
