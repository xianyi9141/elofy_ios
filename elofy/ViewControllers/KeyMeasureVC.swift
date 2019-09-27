//
//  KeyMeasureVC.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftValidators
import Popover
import SwiftyJSON
import CDAlertView

class KeyMeasureVC: CommonVC {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var responsible: UILabel!
    @IBOutlet weak var from: UILabel!
    @IBOutlet weak var to: UILabel!
    @IBOutlet weak var actual: UILabel!
    @IBOutlet weak var progress: UILabel!
    @IBOutlet weak var unit: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var inputForm: UIView!
    @IBOutlet weak var inputFormBottom: NSLayoutConstraint!
    @IBOutlet weak var newTimestamp: SkyFloatingLabelTextField!
    @IBOutlet weak var newValue: SkyFloatingLabelTextField!
    @IBOutlet weak var newDescription: UITextView!
    @IBOutlet weak var newDescriptionBar: UIView!

    var resultKey: ResultKey!

    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = resultKey.title
        responsible.text = "\(resultKey.user.name)\(resultKey.user.id == getInt(key: .id) ? " (Me)" : "")"
        from.text = "\(resultKey.from)"
        to.text = "\(resultKey.to)"
        actual.text = "\(resultKey.actual)"
        progress.text = "\(Int(resultKey.percentage))%"
        unit.text = resultKey.unit
        timestamp.text = "Carregando..."

        inputFormBottom.constant = inputForm.bounds.height
        view.layoutIfNeeded()

        loadHistory()
    }

    func loadHistory() {
        get(url: "/measurement/\(resultKey.id)", indicator: false) { res in
            let json = JSON(res.arrayBody)
            self.timestamp.text = json.arrayValue.first?["date"].stringValue.toDate() ?? self.resultKey.timestamp.toDate()
            if self.timestamp.text?.isEmpty ?? true {
                self.timestamp.text = "n/a"
            }
        }
    }

    @IBAction func onAddAction(_ sender: UIButton) {
        inputFormBottom.constant = 0
        UIView.animate(withDuration: 0.3, animations: {
            sender.alpha = 0
            self.view.layoutIfNeeded()
        }) { _ in
            sender.isHidden = true
        }
    }

    func validate() -> Bool {
        if Validator.isEmpty().apply(newTimestamp.text) {
            self.view.makeToast("Por favor informe um data.", duration: 2, position: .top)
        } else if !Validator.isDate("dd/MM/yyyy").apply(newTimestamp.text) {
            self.view.makeToast("Formato da data inválido.", duration: 2, position: .top)
        } else if Validator.isEmpty().apply(newValue.text) {
            self.view.makeToast("Por favor informe um valor.", duration: 2, position: .top)
        } else if !Validator.isFloat().apply(newValue.text) {
            self.view.makeToast("Valor deve ser numerico.", duration: 2, position: .top)
        } else {
            return true
        }
        return false
    }

    @IBAction func onSaveAction(_ sender: UIButton) {
        view.endEditing(true)

        guard validate() else { return }

        let params: [String: Any] = [
            "id": resultKey.id,
            "date": newTimestamp.text!.toDate(from: "dd/MM/yyyy", to: "yyyy-MM-dd"),
            "value": newValue.text!,
            "description": newDescription.text ?? ""
        ]
        post(url: "/measurement", params: params) { res in
            let json = JSON(res.dictionaryBody)
            if json["status"].intValue == 1 {
                let alert = CDAlertView(title: "Parabéns!", message: "", type: .success)
                alert.circleFillColor = .sky
                alert.titleFont = UIFont.systemFont(ofSize: 20)
                alert.titleTextColor = .sky

                let message = NSMutableAttributedString(string: "Bom trabalho!\n", attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.sky,
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 17)
                    ]
                )
                message.append(NSAttributedString(string: "Bom trabalho, key result atualizado com sucesso!", attributes: [
                    NSAttributedStringKey.foregroundColor: UIColor.darkGray,
                    NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)
                    ])
                )
                let label = UILabel()
                label.attributedText = message
                label.numberOfLines = 0
                label.textAlignment = .center
                alert.customView = label

                let okay = CDAlertViewAction(
                    title: "Vá para página de objetivos",
                    textColor: .white,
                    backgroundColor: .sky,
                    handler: { _ in
                        self.performSegue(withIdentifier: "unwind2Goals", sender: nil)
                        return true
                    })
                alert.add(action: okay)
                alert.show()
            } else {
                self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
            }
        }
    }
}

extension KeyMeasureVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === newTimestamp {
            view.endEditing(true)
            let picker = UIDatePicker()
            picker.datePickerMode = .date
            picker.sizeToFit()
            Popover(showHandler: nil) {
                let formatter = DateFormatter()
                formatter.dateFormat = "dd/MM/yyyy"
                self.newTimestamp.text = formatter.string(from: picker.date)
            }.show(picker, fromView: newTimestamp)
            return false
        }
        return true
    }
}
