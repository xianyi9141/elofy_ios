//
//  SurveysVC.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON

class SurveysVC: CommonVC {
    var surveys: [Survey] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // tableview
        tableView.register(UINib(nibName: "SurveyCell", bundle: nil), forCellReuseIdentifier: "SurveyCell")
        tableView.refreshControl = refreshControl

        // load data
        loadSurveys()
    }

    func loadSurveys(indicator: Bool = true) {
        get(url: "/surveys", indicator: indicator) { res in
            self.refreshControl.endRefreshing()
            let json = JSON(res.arrayBody)
            self.surveys = json.arrayValue.map(Survey.init)
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()
        }
    }

    override func onPullRefresh() {
        loadSurveys(indicator: false)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "surveyDetail", let vc = segue.destination as? SurveyDetailVC, let index = sender as? Int {
            vc.survey = surveys[index]
        }
    }

    @IBAction func unwind2Surveys(_ segue: UIStoryboardSegue) {
        if segue.source is SurveyDetailVC {
            loadSurveys()
        }
    }
}

extension SurveysVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return surveys.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SurveyCell", for: indexPath) as! SurveyCell
        cell.survey = surveys[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if !surveys[indexPath.row].isAnswered {
            performSegue(withIdentifier: "surveyDetail", sender: indexPath.row)
        }
    }
}
