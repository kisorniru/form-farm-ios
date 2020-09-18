//
//  NetworkManager.swift
//  FormFarm
//
//  Created by Герасимов Тимофей Владимирович on 17.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Reachability
import UIKit

class NetworkManager: NSObject {
    
    static let sharedInstance: NetworkManager = { return NetworkManager() }()
    
    var reachability: Reachability!
    
    override init() {
        super.init()
        do {
            reachability = try Reachability()
        } catch {
            print(error)
        }
        
        
        // Register an observer for the network status
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(networkStatusChanged(_:)),
            name: .reachabilityChanged,
            object: reachability
        )
        
        do {// Start the network status notifier
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func networkStatusChanged(_ notification: Notification) {
        // Do something globally here!
    }
    
    static func stopNotifier() -> Void {
        do {// Stop the network status notifier
            try (NetworkManager.sharedInstance.reachability).startNotifier()
        } catch {
            print("Error stopping notifier")
        }
    }
    
    static func isReachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection != .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isUnreachable(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .none {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWWAN(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .cellular {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    static func isReachableViaWiFi(completed: @escaping (NetworkManager) -> Void) {
        if (NetworkManager.sharedInstance.reachability).connection == .wifi {
            completed(NetworkManager.sharedInstance)
        }
    }
    
    func checkNetworkConnect(network: NetworkManager, completion: @escaping (_ isConnect: Bool) -> Void) {
        NetworkManager.isReachable { _ in
            print("Network is reachable")
            completion(true)
        }
        NetworkManager.isUnreachable { _ in
            print("Network is unreachable")
            completion(false)
        }
        network.reachability.whenReachable = { _ in
            print("Network when reachable")
            completion(true)
        }
        network.reachability.whenUnreachable = { _ in
            print("Network when unreachable")
            completion(false)
        }
    }
    
}
