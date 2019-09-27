//
//  UpdatesVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON

class UpdatesVC: CommonVC {
    var updates: [Update] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "UpdateCell", bundle: nil), forCellReuseIdentifier: "UpdateCell")
        tableView.refreshControl = refreshControl

        loadUpdates()
    }

    func loadUpdates(indicator: Bool = true) {
        get(url: "/timeline", indicator: indicator) { res in
            self.refreshControl.endRefreshing()
            let json = JSON(res.dictionaryBody)
            if json["status"].intValue == 1 {
                self.updates = json["feeds"].arrayValue.map(Update.init)
                self.tableView.emptyDataSetSource = self
                self.tableView.emptyDataSetDelegate = self
                self.tableView.reloadData()
            } else {
                self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
            }
        }
    }

    override func onPullRefresh() {
        loadUpdates(indicator: false)
    }
}

extension UpdatesVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return updates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateCell", for: indexPath) as! UpdateCell

        cell.update = updates[indexPath.row]
        cell.top.isHidden = indexPath.row == 0
        cell.bottom.isHidden = indexPath.row == updates.count - 1

        return cell
    }
}
