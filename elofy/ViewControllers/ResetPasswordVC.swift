//
//  ResetPasswordVC.swift
//  elofy
//
//  Created by raptor on 01/03/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import CDAlertView
import SkyFloatingLabelTextField
import SwiftValidators
import SwiftyJSON

class ResetPasswordVC: CommonVC {
    @IBOutlet weak var email: SkyFloatingLabelTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSubmiteAction(_ sender: UIButton) {
        if Validator.isEmpty().apply(email.text) {
            self.view.makeToast("Por favor informe um e-mail.", duration: 2, position: .top)
        } else if !Validator.isEmail().apply(email.text) {
            self.view.makeToast("E-mail inválido.", duration: 2, position: .top)
        } else {
            self.post(url: "/resetpassword", params: ["email": email.text!]) { res in
                let json = JSON(res.dictionaryBody)
                if json["status"].intValue == 0 {
                    self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
                } else {
                    let alert = CDAlertView(title: "Email enviado!", message: "Nós enviamos um email para \(self.email.text!) com as as instruções e link para alterar a senha.", type: .success)
                    let ok = CDAlertViewAction(title: "Okay", textColor: .white, backgroundColor: .sky)
                    alert.add(action: ok)
                    alert.show()
                }
            }
        }
    }

    @IBAction func onClose(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
