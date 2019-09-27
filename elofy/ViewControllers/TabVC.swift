//
//  TabVC.swift
//  elofy
//
//  Created by raptor on 24/02/2018.
//  Copyright © 2018 raptor. All rights reserved.
//

import UIKit

enum TabPage: Int {
    case goal, elos, okrs, surveys
}

/*
 *  0: goals, 1: activities, 2: elos, 3: update, 4: surveys
 *
 */
class TabVC: UITabBarController {
    var page: TabPage!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        navigationItem.hidesBackButton = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if page == .elos {
            selectedIndex = 2
        } else if page == .surveys {
            selectedIndex = 4
        } else {
            selectedIndex = 0
        }
    }

//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        // surveys
//        if selectedIndex == 4 {
//            self.view.makeToast("Pesquisas em breve...", duration: 2, position: .top)
//        }
//    }
}

