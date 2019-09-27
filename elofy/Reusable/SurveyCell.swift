//
//  SurveyCell.swift
//  elofy
//
//  Created by raptor on 22/03/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

class SurveyCell: UITableViewCell {
    @IBOutlet weak var imagebg: UIView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var timestamp: UILabel!

    var survey: Survey! {
        didSet {
            setup()
        }
    }

    func setup() {
        accessoryType = survey.isAnswered ? .none : .disclosureIndicator
        imagebg.backgroundColor = survey.isAnswered ? .gray : .sky
        imageLabel.text = survey.userName?.uppercased().first?.description
        title.text = survey.name
        count.text = "\(survey.count) pessoas responderam"
        timestamp.text = "Atualizado \(survey.timestamp?.toDate() ?? "n/a")"
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        imagebg.backgroundColor = survey.isAnswered ? .gray : .sky
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        imagebg.backgroundColor = survey.isAnswered ? .gray : .sky
    }
}
