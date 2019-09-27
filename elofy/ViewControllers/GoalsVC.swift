//
//  GoalsVC.swift
//  elofy
//
//  Created by raptor on 27/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Segmentio
import LGButton
import CDAlertView
import SwiftyJSON

class GoalsVC: CommonVC {
    @IBOutlet weak var tag: Segmentio!
    @IBOutlet weak var filterBar: UIStackView!

    var filterView: SearchFilterView?
    var searchText: String = ""

    var goals: [Goal]?
    var okrs: [Goal]?
    var filteredOKRs: [Goal] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // tableview
        tableView.register(UINib(nibName: "GoalCell", bundle: nil), forCellReuseIdentifier: "GoalCell")
        tableView.refreshControl = refreshControl

        // tag
        tag.setup(
            content: [
                SegmentioItem(title: "Meus Objetivos", image: nil),
                SegmentioItem(title: "Objetivos da Empresa", image: nil)
            ],
            style: .onlyLabel,
            options: SegmentioOptions(
                backgroundColor: .clear,
                segmentPosition: .dynamic,
                scrollEnabled: false,
                indicatorOptions: SegmentioIndicatorOptions(type: .bottom, ratio: 1, height: 2, color: .sky),
                horizontalSeparatorOptions: SegmentioHorizontalSeparatorOptions(type: .bottom, height: 2, color: .groupTableViewBackground),
                verticalSeparatorOptions: nil,
                imageContentMode: .top,
                labelTextAlignment: .center,
                labelTextNumberOfLines: 1,
                segmentStates: SegmentioStates(
                    defaultState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 20),
                        titleTextColor: .lightGray
                    ),
                    selectedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 20),
                        titleTextColor: .sky
                    ),
                    highlightedState: SegmentioState(
                        backgroundColor: .clear,
                        titleFont: UIFont.systemFont(ofSize: 22),
                        titleTextColor: .sky
                    )
                ),
                animationDuration: 0.3)
        )
        tag.valueDidChange = { _, index in
            if index == 0 {
                // goals
                self.filterBar.isHidden = true
                if let _ = self.goals {
                    self.tableView.reloadData()
                } else {
                    self.loadGoals()
                }
            } else {
                // okrs
                self.filterBar.isHidden = false
                if let _ = self.okrs {
                    self.tableView.reloadData()
                } else {
                    self.loadOKRs()
                }
            }
        }

        // initial load for goal
        if let tabVC = tabBarController as? TabVC, tabVC.page == .okrs {
            tag.selectedSegmentioIndex = 1
        } else {
            tag.selectedSegmentioIndex = 0
        }
    }

    func loadGoals(indicator: Bool = true) {
        get(url: "/goals", indicator: indicator) { res in
            self.refreshControl.endRefreshing()
            let json = JSON(res.arrayBody)
            self.goals = json.arrayValue.map(Goal.init)
            self.tableView.emptyDataSetSource = self
            self.tableView.emptyDataSetDelegate = self
            self.tableView.reloadData()
        }
    }

    func loadOKRs(indicator: Bool = true) {
        get(url: "/okrs", indicator: indicator) { res in
            self.refreshControl.endRefreshing()
            let json = JSON(res.arrayBody)
            self.okrs = json.arrayValue.map(Goal.init)
            self.filterOKRs()
        }
    }

    override func onPullRefresh() {
        if tag.selectedSegmentioIndex == 0 {
            loadGoals(indicator: false)
        } else {
            loadOKRs(indicator: false)
        }
    }

    func filterOKRs() {
        filteredOKRs.removeAll()
        filteredOKRs.append(contentsOf: okrs ?? [])
        if let filter = filterView?.selection[.status], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter { filter.contains($0.color.rawValue.description) }
        }
        if let filter = filterView?.selection[.responsible], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter { filter.contains($0.user.id.description) }
        }
        if let filter = filterView?.selection[.team], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter { $0.team != nil && filter.contains($0.team!.id.description) }
        }
        if let filter = filterView?.selection[.year], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter { $0.year != nil && filter.contains($0.year!) }
        }
        if let filter = filterView?.selection[.quarter], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter {
                let ids = $0.cycles.map { c in c.id.description }
                return Array(Set(filter + ids)).count != (filter.count + ids.count)
            }
        }
        if let filter = filterView?.selection[.goal], !filter.isEmpty {
            filteredOKRs = filteredOKRs.filter { filter.contains($0.parentId.description) }
        }
        if !searchText.isEmpty {
            filteredOKRs = filteredOKRs.filter { $0.raw.contains(searchText.lowercased()) }
        }

        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        tableView.reloadData()
    }

    @IBAction func onFilterAction(_ sender: LGButton) {
        if let _ = filterView {
            presentFilterDialog()
        } else {
            filterView = SearchFilterView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 28, height: 300))
            self.filterView?.onYearChanged = { filterView, year in
                self.get(url: "/filter/\(year)") { res in
                    let json = JSON(res.dictionaryBody)
                    filterView.dataSource[.quarter]?.append(
                        contentsOf: json["quarters"].arrayValue.map { (id: $0["id"].stringValue, name: $0["name"].stringValue) }
                    )
                    filterView.dataSource[.goal]?.append(
                        contentsOf: json["goals"].arrayValue.map { (id: $0["id"].stringValue, name: $0["title"].stringValue) }
                    )
                    filterView.resetByYear()
                }
            }
            get(url: "/filters") { res in
                let json = JSON(res.dictionaryBody)
                self.filterView?.dataSource[.responsible]? .append(
                    contentsOf: json["responsible"].arrayValue.map { (id: $0["id"].stringValue, name: $0["name"].stringValue) }
                )
                self.filterView?.dataSource[.team]?.append(
                    contentsOf: json["teams"].arrayValue.map { (id: $0["id"].stringValue, name: $0["name"].stringValue) }
                )
                self.filterView?.dataSource[.year]?.append(
                    contentsOf: json["years"].arrayValue.map { (id: $0.stringValue, name: $0.stringValue) }
                )

                self.presentFilterDialog()
            }
        }

    }

    func presentFilterDialog() {
        let alert = CDAlertView(title: "Filtros para pesquisa", message: "", type: .custom(image: #imageLiteral(resourceName: "filter")))
        alert.circleFillColor = .sky
        alert.titleFont = UIFont.systemFont(ofSize: 22)
        alert.popupWidth = view.bounds.width - 28
        alert.customView = filterView

        let cancel = CDAlertViewAction(title: "Cancelar", textColor: .sky)
        let apply = CDAlertViewAction(title: "Aplicar", textColor: .white, backgroundColor: .sky, handler: { _ in
            self.filterOKRs()
            return true
        })

        alert.add(action: cancel)
        alert.add(action: apply)
        alert.show()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goalDetail", let vc = segue.destination as? GoalDetailVC, let index = sender as? Int {
            vc.goal = tag.selectedSegmentioIndex == 0 ? goals![index] : filteredOKRs[index]
            vc.onUpdateAction = {
                if self.tag.selectedSegmentioIndex == 0 {
                    self.loadGoals()
                } else {
                    self.loadOKRs()
                }
            }
        }
    }

    @IBAction func unwind2Goals(_ segue: UIStoryboardSegue) {
        if segue.source is KeyMeasureVC {
            if tag.selectedSegmentioIndex == 0 {
                loadGoals()
            } else {
                loadOKRs()
            }
        }
    }
}

extension GoalsVC: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tag.selectedSegmentioIndex == 0 ? (goals?.count ?? 0) : (filteredOKRs.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! GoalCell

        cell.myId = getInt(key: .id)
        cell.goal = tag.selectedSegmentioIndex == 0 ? goals![indexPath.row] : filteredOKRs[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tag.selectedSegmentioIndex == 0, let _ = goals {
            self.performSegue(withIdentifier: "goalDetail", sender: indexPath.row)
        } else if tag.selectedSegmentioIndex == 1 {
            self.performSegue(withIdentifier: "goalDetail", sender: indexPath.row)
        }
    }
}

extension GoalsVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
            self.searchText = searchText
            self.filterOKRs()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        self.filterOKRs()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = true
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        UIView.animate(withDuration: 0.3) {
            searchBar.showsCancelButton = false
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()

        self.searchText = ""
        filterOKRs()
    }
}
