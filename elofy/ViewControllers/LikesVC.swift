//
//  LikesVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import SwiftyJSON
import Toast_Swift
import Hakawai
import IQKeyboardManagerSwift

class LikesVC: CommonVC {
	@IBOutlet weak var textBox: HKWTextView!

	var likes: [Like] = []
	var mentions: [MentionUser]?
	var mentionPlugin: HKWMentionsPlugin!
	var ignoreTextBoxDismiss: Bool = false
	var textBoxEditing: Bool = false {
		didSet {
			if textBoxEditing {
				textBox.superview?.constraint("height")?.constant = 120
				UIView.animate(withDuration: 0.3, animations: {
					self.view.layoutIfNeeded()
				}) { _ in
					IQKeyboardManager.sharedManager().enable = false
				}
			} else {
				IQKeyboardManager.sharedManager().enable = true
				textBox.superview?.constraint("height")?.constant = 40
				UIView.animate(withDuration: 0.3) {
					self.view.layoutIfNeeded()
				}
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		IQKeyboardManager.sharedManager().previousNextDisplayMode = .alwaysHide
		IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = false

		NotificationCenter.default.addObserver(self,
			selector: #selector(keyboardWillShow),
			name: NSNotification.Name.UIKeyboardWillShow,
			object: nil)

	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// tableview
		tableView.register(UINib(nibName: "LikeCell", bundle: nil), forCellReuseIdentifier: "LikeCell")
		tableView.refreshControl = refreshControl

		// mention textview
		mentionPlugin = HKWMentionsPlugin(
			chooserMode: .enclosedTop,
			controlCharacters: ["@"],
			searchLength: 0,
			unselectedMentionAttributes: [
				NSAttributedStringKey.foregroundColor: UIColor.blue,
				NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)
			],
			selectedMentionAttributes: [
				NSAttributedStringKey.foregroundColor: UIColor.blue,
				NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 15)
			])
		mentionPlugin?.resumeMentionsCreationEnabled = true
		mentionPlugin?.chooserViewEdgeInsets = UIEdgeInsets(top: 2, left: 0.5, bottom: 0.5, right: 0.5)
		mentionPlugin?.delegate = self
		textBox.controlFlowPlugin = mentionPlugin
		textBox.autocorrectionType = .no
		textBox.addDoneOnKeyboardWithTarget(self, action: #selector(LikesVC.endTextBoxEditing))

		loadLikes()
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		IQKeyboardManager.sharedManager().previousNextDisplayMode = .Default
		IQKeyboardManager.sharedManager().shouldShowToolbarPlaceholder = true
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
	}

	func loadLikes(indicator: Bool = true) {
		get(url: "/comments", indicator: indicator) { res in
			self.refreshControl.endRefreshing()
			let json = JSON(res.dictionaryBody)
			self.likes = json["elos"].arrayValue.map(Like.init)
			self.tableView.emptyDataSetSource = self
			self.tableView.emptyDataSetDelegate = self
			self.tableView.reloadData()
		}
	}

	override func onPullRefresh() {
		loadLikes(indicator: false)
	}

	@IBAction func onAddComment(_ sender: Any) {
		endTextBoxEditing()

		guard !textBox.text.isEmpty else { return }
		guard let users = mentionPlugin.mentions() as? [HKWMentionsAttribute], !users.isEmpty else {
			self.view.makeToast("Por favor informe @ e o nome do usuário.", duration: 2, position: .top)
			return
		}

		let params: [String: Any] = [
			"comment": textBox.text!,
			"users": users.map { $0.entityId()! }.joined(separator: ",")
		]
		post(url: "/comments", params: params) { res in
			let json = JSON(res.dictionaryBody)
			if json["status"].intValue == 1 {
				self.textBox.text = ""
				self.loadLikes()
			} else {
				self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
			}
		}
	}
}

extension LikesVC {
	@objc func keyboardWillShow(notification: NSNotification) {
		if !textBoxEditing, textBox.isFirstResponder {
			textBoxEditing = true
		}
		if !textBox.isFirstResponder {
			textBoxEditing = false
		}
	}

	@objc func endTextBoxEditing() {
		textBoxEditing = false
		textBox.resignFirstResponder()
	}
}

extension LikesVC: HKWMentionsDelegate, HKWMentionsStateChangeDelegate {
	func asyncRetrieveEntities(forKeyString keyString: String!, searchType type: HKWMentionsSearchType, controlCharacter character: unichar, completion completionBlock: (([Any]?, Bool, Bool) -> Void)!) {
		if let mentions = self.mentions {
			if keyString.isEmpty {
				completionBlock(mentions, false, true)
			} else {
				let keyStr = keyString.lowercased()
				let match = mentions.filter { $0.name.lowercased().contains(keyStr) }
				completionBlock(match, false, true)
			}
		} else {
			get(url: "/mentionusers", indicator: false) { res in
				let json = JSON(res.arrayBody)
				self.mentions = json.arrayValue.map(MentionUser.init)

				if keyString.isEmpty {
					completionBlock(self.mentions!, false, true)
				} else {
					let keyStr = keyString.lowercased()
					let match = self.mentions!.filter { $0.name.lowercased().contains(keyStr) }
					completionBlock(match, false, true)
				}
			}
		}
	}

	func cell(forMentionsEntity entity: HKWMentionsEntityProtocol!, withMatch matchString: String!, tableView: UITableView!) -> UITableViewCell! {
		var cell = tableView.dequeueReusableCell(withIdentifier: "mentionsCell")
		if cell == nil {
			cell = UITableViewCell(style: .default, reuseIdentifier: "mentionsCell")
		}

		cell!.textLabel?.text = entity.entityName()

		return cell!
	}

	func heightForCell(forMentionsEntity entity: HKWMentionsEntityProtocol!, tableView: UITableView!) -> CGFloat {
		return 40
	}
}

extension LikesVC: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return likes.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "LikeCell", for: indexPath) as! LikeCell

		cell.like = likes[indexPath.row]
		cell.beginUpdate = { tableView.beginUpdates() }
		cell.endUpdate = { tableView.endUpdates() }
		cell.onLike = {
			self.get(url: "/likecomment/\(self.likes[indexPath.row].id)") { res in
				let json = JSON(res.dictionaryBody)
				if json["status"].intValue == 1 {
					self.likes[indexPath.row].liked = true
					self.likes[indexPath.row].likesCnt += 1
					cell.like.liked = true
					cell.like.likesCnt = self.likes[indexPath.row].likesCnt
					cell.update()
				} else {
					self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
				}
			}
		}
		cell.onRequestComments = {
			self.get(url: "/comment/\(self.likes[indexPath.row].id)") { res in
				let json = JSON(res.dictionaryBody)
				self.likes[indexPath.row].comments = json["comments"].arrayValue.map {
					(id: $0["id"].intValue, name: $0["username"].stringValue, comment: $0["comment_text"].stringValue)
				}
				cell.like.comments = self.likes[indexPath.row].comments
				cell.like.expanded = true
				cell.update()
			}
		}
		cell.onAddComment = { text in
			guard let text = text, !text.isEmpty else { return }
			self.post(url: "/comment/\(self.likes[indexPath.row].id)", params: ["comment": text]) { res in
				let json = JSON(res.dictionaryBody)
				if json["status"].intValue == 1 {
					if let _ = self.likes[indexPath.row].comments {
						self.likes[indexPath.row].comments?.insert((id: self.getInt(key: .id), name: self.getString(key: .name) ?? "", comment: text), at: 0)
					}
					self.likes[indexPath.row].commentsCnt += 1
					cell.like.comments = self.likes[indexPath.row].comments
					cell.like.commentsCnt = self.likes[indexPath.row].commentsCnt
					cell.textbox.text = nil
					cell.update()
				} else {
					self.view.makeToast(json["message"].stringValue, duration: 2, position: .top)
				}
			}
		}
		cell.update()

		return cell
	}
}
