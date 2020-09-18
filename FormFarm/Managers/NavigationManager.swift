//
//  NavigationManager.swift
//  FormFarm
//
//  Created by a1 on 22.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

class NavigationManager {
    
    class LoginNVC: UINavigationController {}
    class MainNVC: UINavigationController {}
    
    static func goToLoginView() {
        let loginStoryboard = UIStoryboard(name: StoryboardNames.login.rawValue, bundle: nil)
        let login = loginStoryboard.instantiateViewController(withIdentifier: IdentifierVC.loginNavVC.rawValue)
        UIApplication.shared.windows[0].rootViewController = login
    }
    
    static func goToMainView() {
        let mainStoryboard = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil)
        let main = mainStoryboard.instantiateViewController(withIdentifier: IdentifierVC.mainNavVC.rawValue)
        UIApplication.shared.windows[0].rootViewController = main
    }
    
}
