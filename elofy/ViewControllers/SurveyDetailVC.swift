//
//  SurveyDetailVC.swift
//  elofy
//
//  Created by raptor on 22/03/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON
import HCSStarRatingView
import BEMCheckBox
import UITextView_Placeholder
import CDAlertView

class SurveyDetailVC: CommonVC {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatarBg: UIView!
    @IBOutlet weak var avatarLabel: UILabel!
    @IBOutlet weak var container: UIStackView!

    var survey: Survey!
    var questions: [Question] = []
    var answersStar: [Int: HCSStarRatingView] = [:]
    var answersHeart: [Int: HCSStarRatingView] = [:]
    var answersText: [Int: UITextView] = [:]
    var answersMultiple: [Int: BEMCheckBoxGroup] = [:]
    var answersAgree: [Int: BEMCheckBoxGroup] = [:]
    let agrees: [(id: Int, text: String)] = [
        (id: 1, "Discordo totalmente"),
        (id: 2, "Discordo"),
        (id: 3, "Neutro"),
        (id: 4, "Concordo"),
        (id: 5, "Totalmente de acordo")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        name.text = survey.name
        avatarBg.backgroundColor = survey.isAnswered ? .gray : .sky
        avatarLabel.text = survey.userName?.uppercased().first?.description

        loadQuestions()
    }

    func loadQuestions() {
        container.isHidden = true
        let params: [String: Any] = [
            "question": survey.questionId.description
        ]
        get(url: "/survey/\(survey.id)", params: params) { res in
            let json = JSON(res.arrayBody)
            self.questions = json.arrayValue.map(Question.init)
            self.questions.forEach { question in
                self.container.insertArrangedSubview(self.questionView(question: question), at: self.container.arrangedSubviews.count - 1)
            }
            self.container.isHidden = false
        }
    }

    @IBAction func onFinishSurvey(_ sender: Any) {
        var answers: [String: Any] = [:]

        // star & agree
        var star: [String: Any] = [:]
        answersStar.forEach {
            if $0.value.value > 0 {
                star[$0.key.description] = [
                    "id_questionario": survey.questionId,
                    "value": Int($0.value.value)
                ]
            } else {
                star[$0.key.description] = [
                    "id_questionario": survey.questionId
                ]
            }
        }
        answersAgree.forEach {
            if let check = $0.value.selectedCheckBox {
                star[$0.key.description] = [
                    "id_questionario": survey.questionId,
                    "value": check.tag
                ]
            } else {
                star[$0.key.description] = [
                    "id_questionario": survey.questionId
                ]
            }
        }
        if !star.isEmpty {
            answers["rating_answer"] = star
        }

        // heart
        var heart: [String: Any] = [:]
        answersHeart.forEach {
            if $0.value.value > 0 {
                heart[$0.key.description] = [
                    "id_questionario": survey.questionId,
                    "value": Int($0.value.value)
                ]
            } else {
                heart[$0.key.description] = [
                    "id_questionario": survey.questionId
                ]
            }
        }
        if !heart.isEmpty {
            answers["heart_answer"] = heart
        }

        // text
        var text: [String: Any] = [:]
        answersText.forEach {
            text[$0.key.description] = [
                "id_questionario": survey.questionId,
                "value": $0.value.text
            ]
        }
        if !text.isEmpty {
            answers["text_answer"] = text
        }

        // multiple
        var multiple: [String: Any] = [:]
        answersMultiple.filter { $0.value.selectedCheckBox != nil }.forEach {
            multiple[$0.key.description] = $0.value.selectedCheckBox!.tag
        }
        if !multiple.isEmpty {
            answers["multiresponse_answer"] = multiple
        }

        // params
        let params: [String: Any] = [
            "id_pesquisa": survey.id,
            "questioerio_id": survey.questionId,
            "answers": JSON(answers).rawString()!
        ]
        post(url: "/survey", params: params) { _ in
            let alert = CDAlertView(title: "Parabéns!", message: "Pesquisa respondida com sucesso.", type: .success)
            alert.circleFillColor = .sky
            alert.titleTextColor = .sky

            let okay = CDAlertViewAction(
                title: "Vá para página de pesquisas",
                textColor: .white,
                backgroundColor: .sky,
                handler: { _ in
                    self.performSegue(withIdentifier: "unwind2Surveys", sender: nil)
                    return true
                })
            alert.add(action: okay)
            alert.show()
        }
    }

    func questionView(question: Question) -> UIStackView {
        let stackView = UIStackView()
        stackView.axis = .vertical

        guard let type = question.type else { return stackView }

        let title = UILabel()
        title.text = question.question
        title.numberOfLines = 0
        stackView.addArrangedSubview(title)

        switch type {
        case .star:
            let stars = HCSStarRatingView()
            stackView.addArrangedSubview(stars)
            stackView.alignment = .leading
            stackView.distribution = .equalSpacing

            stars.minimumValue = 0
            stars.maximumValue = 5
            stars.value = 0
            stars.emptyStarImage = #imageLiteral(resourceName: "star")
            stars.filledStarImage = #imageLiteral(resourceName: "star_d")
            stars.starBorderColor = .sky
            stars.allowsHalfStars = false
            stars.accurateHalfStars = false
            stars.continuous = true
            stars.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.5).isActive = true

            answersStar[question.queryId] = stars

        case .heart:
            let hearts = HCSStarRatingView()
            stackView.addArrangedSubview(hearts)

            hearts.minimumValue = 0
            hearts.maximumValue = 10
            hearts.value = 0
            hearts.emptyStarImage = #imageLiteral(resourceName: "heart")
            hearts.filledStarImage = #imageLiteral(resourceName: "heart_d")
            hearts.starBorderColor = .sky
            hearts.allowsHalfStars = false
            hearts.accurateHalfStars = false
            hearts.continuous = true

            answersHeart[question.queryId] = hearts

        case .text:
            let textView: UITextView = UITextView()
            stackView.addArrangedSubview(textView)
            stackView.spacing = 8

            textView.font = UIFont.systemFont(ofSize: 15)
            textView.attributedPlaceholder = NSAttributedString(string: "Descreva sua resposta aqui", attributes: [
                    .font: UIFont.systemFont(ofSize: 15),
                    .foregroundColor: UIColor.gray
                ])
            textView.layer.cornerRadius = 4
            textView.layer.borderColor = UIColor.lightGray.cgColor
            textView.layer.borderWidth = 1
            textView.heightAnchor.constraint(equalToConstant: 128).isActive = true

            answersText[question.queryId] = textView

        case .agree:
            stackView.spacing = 8
            var checks: [BEMCheckBox] = []
            agrees.forEach { agree in
                let optionView = UIStackView()
                optionView.axis = .horizontal
                optionView.alignment = .top
                optionView.spacing = 8

                let check = BEMCheckBox()
                check.widthAnchor.constraint(equalToConstant: 20).isActive = true
                check.heightAnchor.constraint(equalToConstant: 20).isActive = true
                check.tag = agree.id
                checks.append(check)
                optionView.addArrangedSubview(check)

                let answer = UILabel()
                answer.text = agree.text
                answer.textColor = .darkGray
                answer.numberOfLines = 0
                answer.isUserInteractionEnabled = true
                answer.tag = question.queryId
                answer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SurveyDetailVC.onTapAgreeCheckBoxLabel(_:))))
                optionView.addArrangedSubview(answer)

                stackView.addArrangedSubview(optionView)
            }
            let group = BEMCheckBoxGroup(checkBoxes: checks)
            group.mustHaveSelection = false

            answersAgree[question.queryId] = group

        case .multiple:
            stackView.spacing = 8
            var checks: [BEMCheckBox] = []
            question.options.forEach { option in
                let optionView = UIStackView()
                optionView.axis = .horizontal
                optionView.alignment = .top
                optionView.spacing = 8

                let check = BEMCheckBox()
                check.widthAnchor.constraint(equalToConstant: 20).isActive = true
                check.heightAnchor.constraint(equalToConstant: 20).isActive = true
                check.tag = option.id
                checks.append(check)
                optionView.addArrangedSubview(check)

                let answer = UILabel()
                answer.text = option.answer
                answer.textColor = .darkGray
                answer.numberOfLines = 0
                answer.isUserInteractionEnabled = true
                answer.tag = question.queryId
                answer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SurveyDetailVC.onTapMultipleCheckBoxLabel(_:))))
                optionView.addArrangedSubview(answer)

                stackView.addArrangedSubview(optionView)
            }
            let group = BEMCheckBoxGroup(checkBoxes: checks)
            group.mustHaveSelection = false

            answersMultiple[question.queryId] = group

        }

        return stackView
    }

    @objc func onTapMultipleCheckBoxLabel(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
            let optionView = label.superview as? UIStackView,
            let check = optionView.arrangedSubviews.first as? BEMCheckBox else {
                return
        }
        answersMultiple[label.tag]?.selectedCheckBox = check
    }

    @objc func onTapAgreeCheckBoxLabel(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel,
            let optionView = label.superview as? UIStackView,
            let check = optionView.arrangedSubviews.first as? BEMCheckBox else {
                return
        }
        answersAgree[label.tag]?.selectedCheckBox = check
    }
}
