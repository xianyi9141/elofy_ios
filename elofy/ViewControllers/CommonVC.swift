//
//  ViewController.swift
//  elofy
//
//  Created by raptor on 23/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit
import Networking
import SwiftyJSON
import Toast_Swift
import DZNEmptyDataSet

enum StoreKey: String {
    case authToken, id, name, email
    case avatarOriginal, avatarXS, avatarMD
    case rememberMe, deviceToken, deviceTokenRefresh
}

class CommonVC: UIViewController {
//    let net: Networking = Networking(baseURL: "http://192.168.0.108/elofy/src/appsurvey/api")
    let net: Networking = Networking(baseURL: "https://app.elofy.com.br/api")
//    let net: Networking = Networking(baseURL: "https://www.elofysistema.com.br/api")

    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()

    func viewWillAppear(_ animated: Bool, _ hiddenNavBar: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(hiddenNavBar, animated: animated)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // background color
        if !(self is LoginVC), !(self is RegisterVC), !(self is ResetPasswordVC) {
            view.backgroundColor = UIColor(rgb: 0xFEFFFE)
        }

        // tableview empty state
        if let tableView = tableView {
            refreshControl.addTarget(self, action: #selector(onPullRefresh), for: .valueChanged)

            tableView.tableFooterView = UIView(frame: CGRect.zero)
        }

        // device token
        if let token = getString(key: . deviceToken), getBool(key: .deviceTokenRefresh), let _ = getString(key: .authToken) {
            post(url: "/devicetoken", params: ["token": token], indicator: false) { _ in
                self.clear(forKey: .deviceTokenRefresh)
            }
        }
    }

    @objc func onPullRefresh() {

    }
}


// navigate
extension CommonVC {
    @IBAction func logout(_ sender: Any? = nil) {
        // clear device token on server
        get(url: "/devicetoken", params: ["token": ""], indicator: false)

        // clear local storage
        let deviceToken = getString(key: .deviceToken);
        clear()
        if let deviceToken = deviceToken {
            set(deviceToken, key: .deviceToken)
            set(true, key: .deviceTokenRefresh)
        }

        // go 2 login vc
        navigationController?.popToRootViewController(animated: true)
        navigationController?.navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func home(_ sender: Any) {
        tabBarController?.navigationController?.popViewController(animated: true)
    }
}


// utility
extension CommonVC {
    public static func periodInMinutesToString(_ diff: Int) -> String {
        let hour: Int = 60
        let day: Int = hour * 24
        let week: Int = day * 7
        let month: Int = day * 30
        let year: Int = day * 365

        if diff / year > 0 { return "\(diff / year) \(diff / year == 1 ? "year" : "years") ago" }
        else if diff / month > 0 { return "\(diff / month) \(diff / month == 1 ? "month" : "months") ago" }
        else if diff / week > 0 { return "\(diff / week) \(diff / week == 1 ? "week" : "weeks") ago" }
        else if diff / day > 0 { return "\(diff / day) \(diff / day == 1 ? "day" : "days") ago" }
        else if diff / hour > 0 { return "\(diff / hour) \(diff / hour == 1 ? "hour" : "hours") ago" }
        else if diff > 0 { return "\(diff) \(diff == 1 ? "minute" : "minutes") ago" }
        else { return "Just ago" }
    }
}



// storage
extension CommonVC {
    func set(_ val: Any, key: StoreKey) {
        UserDefaults.standard.set(val, forKey: key.rawValue)
    }

    func getString(key: StoreKey) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    func getInt(key: StoreKey) -> Int {
        return UserDefaults.standard.integer(forKey: key.rawValue)
    }

    func getBool(key: StoreKey) -> Bool {
        return UserDefaults.standard.bool(forKey: key.rawValue)
    }

    func clear(forKey: StoreKey) {
        UserDefaults.standard.removeObject(forKey: forKey.rawValue)
    }

    func clear() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}



// sever api
extension CommonVC {
    func handleResponse(url: String, result: JSONResult, completion: ((_ res: SuccessJSONResponse) -> Void)?) {
        switch result {
        case .success(let res):
            print("[$] response [\(url)] Success : \(res)")
            completion?(res)

        case .failure(let res):
            print("[$] response [\(url)] Failed : \(res.statusCode)")

            let json = JSON(res.dictionaryBody)
            switch res.statusCode {
            case 200:
                print("Error message: \(res.error.localizedFailureReason ?? "Unknown")")

            case 401: // authentication failed
                if let _ = getString(key: .authToken) {
                    logout()
                }

            case 400: // validation failed
                var errorMsg = ""
                let errorJson = JSON(json["errors"].dictionaryValue)
                for (_, errors): (String, JSON) in errorJson {
                    errorMsg += errors.arrayValue.map { $0.stringValue }.joined(separator: "\n")
                }
                self.view.makeToast(errorMsg, duration: 2, position: .top)

            case 404: // not found url
                print("Invalid page, make suer url is correct: 404")

            default:
                self.view.makeToast("Algo deu errado, tente novamente.", duration: 2, position: .top)
            }
        }
    }

    func get(url: String, params: [String: Any]? = nil, indicator: Bool = true, completion: ((_ res: SuccessJSONResponse) -> Void)? = nil) {
        if indicator {
            view.makeToastActivity(.center)
            view.isUserInteractionEnabled = false
        }

        print("[$] GET: \(url)")
        if let token = getString(key: .authToken) {
            net.setAuthorizationHeader(token: token)
        }
        net.get(url, parameters: params) { result in
            if indicator {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }

    func post(url: String, params: [String: Any]? = nil, indicator: Bool = true, completion: ((_ res: SuccessJSONResponse) -> Void)? = nil) {
        if indicator {
            view.makeToastActivity(.center)
            view.isUserInteractionEnabled = false
        }

        print("[$] POST: \(url)")
        if let token = getString(key: .authToken) {
            net.setAuthorizationHeader(token: token)
        }
        net.post(url, parameterType: .formURLEncoded, parameters: params) { result in
            if indicator {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }

    func postMultiPart(url: String, params: [String: Any]? = nil, parts: [FormDataPart], indicator: Bool = true, completion: ((_ res: SuccessJSONResponse) -> Void)? = nil) {
        if indicator {
            view.makeToastActivity(.center)
            view.isUserInteractionEnabled = false
        }

        print("[$] Multipart/Form Data: \(url)")
        if let token = getString(key: .authToken) {
            net.setAuthorizationHeader(token: token)
        }
        net.post(url, parameters: params, parts: parts) { result in
            if indicator {
                self.view.hideToastActivity()
                self.view.isUserInteractionEnabled = true
            }
            self.handleResponse(url: url, result: result, completion: completion)
        }
    }
}



// Empty State

extension CommonVC: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "no_entry")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let attrs = [
            NSAttributedStringKey.foregroundColor: UIColor(rgb: 0xAAAAAA),
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20)
        ]
        return NSAttributedString(string: "Sem resultados.", attributes: attrs)
    }
    
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}

