//
//  RegisterVC.swift
//  elofy
//
//  Created by raptor on 23/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import BEMCheckBox
import SwiftyJSON
import SwiftValidators
import CDAlertView

class RegisterVC: CommonVC {
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var business: SkyFloatingLabelTextField!
    @IBOutlet weak var username: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPassword: SkyFloatingLabelTextField!
    @IBOutlet weak var agree: BEMCheckBox!

    override func viewDidLoad() {
        super.viewDidLoad()

        // square checkbox
        agree.boxType = .square
    }

    @IBAction func OnRegisterAction(_ sender: Any) {
        if !Validator.isEmail().apply(email.text) {
            view.makeToast("E-mail inválido.", duration: 2, position: .top)
            email.becomeFirstResponder()
        } else if Validator.isEmpty().apply(business.text) {
            view.makeToast("Nome da empresa dever ser preenchido.", duration: 2, position: .top)
            business.becomeFirstResponder()
        } else if Validator.isEmpty().apply(username.text) {
            view.makeToast("Nome do usuário deve ser preenchido.", duration: 2, position: .top)
            username.becomeFirstResponder()
        } else if Validator.isEmpty().apply(password.text) {
            view.makeToast("Senha deve ser preenchida.", duration: 2, position: .top)
            password.becomeFirstResponder()
        } else if !Validator.equals(password.text!).apply(confirmPassword.text) {
            view.makeToast("Senha não confere.", duration: 2, position: .top)
            confirmPassword.becomeFirstResponder()
        } else if !agree.on {
            view.makeToast("Você deve estar de acordo com termos e condições.", duration: 2, position: .top)
        } else {
            let params: [String: Any] = [
                "email": email.text!,
                "businessName": business.text!,
                "username": username.text!,
                "password": password.text!,
                "confirmPassword": confirmPassword.text!,
                "agree": agree.on ? 1 : 0
            ]
            post(url: "/register", params: params) { res in
                let json = JSON(res.dictionaryBody)
                if json["status"].intValue == 1 {
                    let alert = CDAlertView(title: "Atualizado com sucesso!", message: "Nós enviamos um email para \(self.email.text!).\nPor favor verifique e confirme.", type: .success)
                    let ok = CDAlertViewAction(title: "Okay", textColor: .white, backgroundColor: .sky, handler: { _ in
                        self.navigationController?.popViewController(animated: true)
                        return true
                    })
                    alert.add(action: ok)
                    alert.show()
                } else {
                    self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
                }
            }
        }
    }
}
