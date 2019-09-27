//
//  LoginVC.swift
//  elofy
//
//  Created by raptor on 23/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import BEMCheckBox
import SwiftValidators
import SwiftyJSON
import CDAlertView

class LoginVC: CommonVC {
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var rememberMe: BEMCheckBox!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated, true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // square checkbox
        rememberMe.boxType = .square

        // remember email
        email.text = getString(key: .email)

        // already logged in?
        if getBool(key: .rememberMe) {
            performSegue(withIdentifier: "main", sender: nil)
        }
    }

    @IBAction func onLoginAction(_ sender: Any) {
        if !Validator.isEmail().apply(email.text) {
            view.makeToast("E-mail inválido.", duration: 2, position: .top)
            email.becomeFirstResponder()
        } else if Validator.isEmpty().apply(password.text) {
            view.makeToast("Senha deve ser preenchida.", duration: 2, position: .top)
            password.becomeFirstResponder()
        } else {
            self.view.resignFirstResponder()
            let params: [String: Any] = [
                "email": email.text!,
                "password": password.text!
            ]
            post(url: "/login", params: params) { res in
                let json = JSON(res.dictionaryBody)
                if let status = json["status"].int, status == 0 {
                    self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
                } else {
                    self.set(json["token"].stringValue, key: .authToken)
                    self.set(json["id"].intValue, key: .id)
                    self.set(json["nome"].stringValue, key: .name)
                    self.set(self.email.text!, key: .email)
                    if let image = json["orignal_image"].string { self.set(image, key: .avatarOriginal) }
                    if let image = json["xs_image"].string { self.set(image, key: .avatarXS) }
                    if let image = json["md_image"].string { self.set(image, key: .avatarMD) }
                    self.set(self.rememberMe.on, key: .rememberMe)
                    self.performSegue(withIdentifier: "main", sender: nil)
                }
            }
        }
    }
}
