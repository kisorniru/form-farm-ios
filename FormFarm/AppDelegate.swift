//
//  AppDelegate.swift
//  FormFarm
//
//  Created by a1 on 22.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit
import RealmSwift
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import Sentry

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var realm = try! Realm()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        HeaderManager.recieve(key: .accessToken).isEmpty ? NavigationManager.goToLoginView() : NavigationManager.goToMainView()
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        // Create a Sentry client and start crash handler
        do {
            Client.shared = try Client(dsn: "https://898102bb0f624713a8883cb3557479c1@sentry.io/1516564")
            try Client.shared?.startCrashHandler()
        } catch let error {
            print("\(error)")
        }
        return true
    }
}

