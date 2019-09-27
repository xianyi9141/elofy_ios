//
//  ActivitiesVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON
import SDWebImage
import CDAlertView

class ActivitiesVC: CommonVC {
    var activities: [Activity] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "ActivityCell", bundle: nil), forCellReuseIdentifier: "ActivityCell")
        tableView.refreshControl = refreshControl

        loadActivities()
    }

    func loadActivities(indicator: Bool = true) {
        get(url: "/activities", indicator: indicator) { res in
            self.refreshControl.endRefreshing()
            let json = JSON(res.dictionaryBody)
            self.activities = json["activities"].arrayValue.map(Activity.init)
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()
        }
    }

    override func onPullRefresh() {
        loadActivities(indicator: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activityDetail", let vc = segue.destination as? ActivityDetailVC, let index = sender as? Int {
            vc.activity = activities[index]
            vc.onUpdateStatus = { status in
                guard status != .none else {
                    return
                }
                guard status != .done else {
                    self.activities.remove(at: index)
                    self.tableView.reloadData()
                    return
                }

                switch status {
                case .pending:
                    self.activities[index].percentage = 0; self.activities[index].atraso = 0
                case .progress:
                    self.activities[index].percentage = 50; self.activities[index].atraso = 0
                case .late:
                    self.activities[index].percentage = 50; self.activities[index].atraso = 1
                default:
                    break
                }
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? ActivityCell {
                    cell.activity = self.activities[index]
                }
            }
        }
    }
}

extension ActivitiesVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityCell", for: indexPath) as! ActivityCell

        let activity = activities[indexPath.row]
        if let image = getString(key: .avatarXS) {
            cell.avatar.sd_setImage(with: URL(string: image), placeholderImage: #imageLiteral(resourceName: "avatar"))
        } else {
            cell.avatar.image = #imageLiteral(resourceName: "avatar")
        }
        cell.activity = activity
        cell.onDelete = {
            let alert = CDAlertView(title: "Confirma", message: "Você tem certeza que deseja deletar essa atividade?", type: .warning)

            let cancel = CDAlertViewAction(
                title: "Cancelar",
                textColor: .sky)
            let delete = CDAlertViewAction(
                title: "Deletar",
                textColor: .white,
                backgroundColor: .sky,
                handler: { _ in
                    self.get(url: "/dismissActivity/\(activity.id)") { res in
                        let json = JSON(res.dictionaryBody)
                        if (json["status"].intValue == 1) {
                            self.tableView.beginUpdates()
                            self.activities.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .fade)
                            self.tableView.endUpdates()
                        } else {
                            self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
                        }
                    }
                    return true
                })

            alert.add(action: cancel)
            alert.add(action: delete)
            alert.show()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "activityDetail", sender: indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
