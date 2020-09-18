//
//  PopoverVC.swift
//  FormFarm
//
//  Created by a1 on 02.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit

class PopoverLogoutVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func logoutActionBtn(_ sender: UIButton) {
        if HeaderManager.recieve(key: .accessToken).isEmpty {
            NavigationManager.goToLoginView()
        } else {
            LibraryAPI.sharedInstance().logoutDataFromServer(success: { successLogout in
                if successLogout {
                    HeaderManager.clear()
                    NavigationManager.goToLoginView()
                }
            }, failure: { error in
                self.showErrorAlert(message: error)
            })
        }
    }
}
