//
//  SearchFilterView.swift
//  elofy
//
//  Created by raptor on 28/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Popover

enum FilterItem: Int {
    case status, responsible, team, year, quarter, goal
}

class SearchFilterView: UIView {
    var view: UIStackView!
    let tableView = UITableView()
    let popover = Popover()

    var dataSource: [FilterItem: [(id: String, name: String)]] = [
            .status: [
                (id: "", name: "Todos"),
                (id: "1", name: "Em dia"),
                (id: "2", name: "Atenção"),
                (id: "3", name: "Atraso")
            ],
            .responsible: [(id: "", name: "Todos")],
            .team: [(id: "", name: "Todos")],
            .year: [(id: "", name: "Todos")],
            .quarter: [(id: "", name: "Todos")],
            .goal: [(id: "", name: "Todos")]
    ]
    var selection: [FilterItem: [String]] = [
            .status: [],
            .responsible: [],
            .team: [],
            .year: [],
            .quarter: [],
            .goal: []
    ]
    var currentItem: FilterItem!
    var canMultipleSelection: Bool { return currentItem == .responsible || currentItem == .team || currentItem == .goal }

    var onYearChanged: ((_ filterView: SearchFilterView, _ year: String) -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }

    func initialize() {
        view = loadViewFromNib()
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: topAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.dataSource = self
        tableView.delegate = self

        updateItem(for: .status)
        updateItem(for: .responsible)
        updateItem(for: .team)
        updateItem(for: .year)
        updateItem(for: .quarter)
        updateItem(for: .goal)
    }

    func loadViewFromNib() -> UIStackView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "SearchFilterView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIStackView

        return view
    }

    @IBAction func onTapFilterItemAction(_ sender: UITapGestureRecognizer) {
        guard let item = sender.view as? UIStackView else { return }
        currentItem = FilterItem(rawValue: item.tag)

        tableView.frame = CGRect(x: 0, y: 0, width: currentItem == .goal ? 300 : 200, height: min(40 * dataSource[currentItem]!.count, 200))
        tableView.reloadData()
        popover.show(tableView, fromView: item.arrangedSubviews[1])
    }

    func didSelectItem() {
        updateItem(for: currentItem)
        if currentItem == .year {
            dataSource[.quarter] = [(id: "", name: "Todos")]
            dataSource[.goal] = [(id: "", name: "Todos")]
            if selection[.year]?.isEmpty ?? false {
                resetByYear()
            } else {
                onYearChanged?(self, selection[.year]!.first!)
            }
        }
    }

    func updateItem(for item: FilterItem) {
        let stackView = view.arrangedSubviews.filter { ($0 as? UIStackView)?.arrangedSubviews[1].tag == item.rawValue }.first as? UIStackView
        let itemView = (stackView?.arrangedSubviews[1] as? UIStackView)?.arrangedSubviews[0] as? UILabel

        if selection[item]!.isEmpty {
            itemView?.text = dataSource[item]![0].name
        } else {
            itemView?.text = selection[item]!.map { id in
                dataSource[item]!.filter { item in item.id == id }.first!.name
            }.joined(separator: ", ")
        }
    }

    func resetByYear() {
        selection[.quarter] = []
        selection[.goal] = []
        updateItem(for: .quarter)
        updateItem(for: .goal)
    }
}

extension SearchFilterView: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[currentItem]!.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")!

        let item = dataSource[currentItem]![indexPath.row]
        cell.textLabel?.text = item.name
        if item.id.isEmpty {
            cell.accessoryType = selection[currentItem]!.isEmpty ? .checkmark : .none
        } else {
            cell.accessoryType = selection[currentItem]!.contains(item.id) ? .checkmark : .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let item = dataSource[currentItem]![indexPath.row]
        if canMultipleSelection { // multiple
            if indexPath.row == 0 {
                selection[currentItem] = []
            } else if selection[currentItem]?.contains(item.id) ?? false {
                selection[currentItem] = selection[currentItem]!.filter { $0 != item.id }
            } else {
                selection[currentItem]?.append(item.id)
            }
            tableView.reloadData()
        } else { // single
            selection[currentItem] = item.id.isEmpty ? [] : [item.id]
            popover.dismiss()
        }
        didSelectItem()
    }
}
