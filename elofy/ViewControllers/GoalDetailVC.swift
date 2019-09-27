//
//  GoalDetailVC.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Segmentio
import SwiftyJSON

class GoalDetailVC: CommonVC {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var percentFull: UIView!
    @IBOutlet weak var percent: UIView!
    @IBOutlet weak var tag: Segmentio!
    @IBOutlet weak var desc: UILabel!

    var goal: Goal!
    var onUpdateAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // tag
        tag.setup(
            content: [
                SegmentioItem(title: "Key Results", image: nil),
                SegmentioItem(title: "Descrição", image: nil)
            ],
            style: .onlyLabel,
            options: SegmentioOptions(
                backgroundColor: .clear,
                segmentPosition: .dynamic,
                scrollEnabled: false,
                indicatorOptions: SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 2, color: .sky),
                horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .topAndBottom, height: 2, color: .groupTableViewBackground),
                verticalSeparatorOptions: nil,
                imageContentMode: .top,
                labelTextAlignment: .center,
                labelTextNumberOfLines: 1,
                segmentStates: SegmentioStates(
                    defaultState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 15),
                        titleTextColor: .black
                    ),
                    selectedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 15),
                        titleTextColor: .sky
                    ),
                    highlightedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 17),
                        titleTextColor: .sky
                    )
                ),
                animationDuration: 0.3)
        )
        tag.selectedSegmentioIndex = 0
        tag.valueDidChange = { _, index in
            let x = index == 0 ? 0 : -self.tableView.bounds.width
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.x = x
                self.desc.frame.origin.x = x + 16 + self.tableView.bounds.width
            })
        }

        // tableview
        tableView.register(UINib(nibName: "ResultKeyCell", bundle: nil), forCellReuseIdentifier: "ResultKeyCell")

        updateUI()
    }

    func updateUI() {
        if goal.user.image.isEmpty {
            avatar.image = #imageLiteral(resourceName: "avatar")
        } else {
            avatar.sd_setImage(with: URL(string: goal.user.image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        }
        goalName.text = goal.title
        username.text = "\(goal.user.name)\(goal.user.id == getInt(key: .id) ? " (Me)" : "")"
        percent.backgroundColor = goal.color.value
        percent.constraint("width")?.constant = CGFloat(goal.percentage) * percentFull.bounds.width / 100
        percentLabel.text = "\(Int(goal.percentage))%"
        desc.text = goal.description

        if let _ = goal.resultKeys {
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            tableView.reloadData()
        } else {
            loadResultKeys()
        }
    }

    func loadResultKeys() {
        get(url: "/goal/\(goal.id)") { res in
            let json = JSON(res.dictionaryBody)
            self.goal.resultKeys = json["keys"].arrayValue.map(ResultKey.init)
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "resultKeyDetail", let vc = segue.destination as? KeyMeasureVC, let key = sender as? ResultKey {
            vc.resultKey = key
        } else if segue.identifier == "activity", let vc = segue.destination as? ActivityDetailVC, let param = sender as? (index: Int, activity: Activity) {
            vc.activity = param.activity
            vc.onUpdateStatus = { status in
                self.get(url: "/goal/\(self.goal.id)") { res in
                    let json = JSON(res.dictionaryBody)
                    self.goal = Goal(json: json)
                    self.updateUI()
                }
                self.onUpdateAction?()
            }
        }
    }
}

extension GoalDetailVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goal.resultKeys?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultKeyCell", for: indexPath) as! ResultKeyCell


        cell.beginUpdate = { tableView.beginUpdates() }
        cell.endUpdate = { tableView.endUpdates() }
        cell.onSettingResultKey = {
            self.performSegue(withIdentifier: "resultKeyDetail", sender: self.goal.resultKeys![indexPath.row])
        }
        cell.onActivityClicked = { activity in
            self.performSegue(withIdentifier: "activity", sender: (index: indexPath.row, activity: activity))
        }
        cell.userId = getInt(key: .id)
        cell.resultKey = goal.resultKeys![indexPath.row]
        cell.update()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard !goal.resultKeys![indexPath.row].activities.isEmpty, let cell = tableView.cellForRow(at: indexPath) as? ResultKeyCell else { return }

        goal.resultKeys![indexPath.row].expanded = !goal.resultKeys![indexPath.row].expanded
        cell.resultKey.expanded = goal.resultKeys![indexPath.row].expanded
        cell.activitiesPanel.isHidden = !cell.resultKey.expanded
        tableView.beginUpdates()
        tableView.endUpdates()
    }
}
