//
//  UIViewController+Extension.swift
//  FormFarm
//
//  Created by a1 on 29.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

protocol AlertProtocol {
    func showAlert(title: String, message: String)
    func showErrorAlert(message: String)
    func showSuccessAlert(message: String)
    func showSuccessAlertWithAction(message: String, handler: ((UIAlertAction) -> Void)?)
}

//MARK: - Show Alerts:
extension UIViewController: AlertProtocol {
    func showSuccessAlertWithAction(message: String, handler: ((UIAlertAction) -> Void)? = nil) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSuccessAlert(message: String) {
        let alert = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
        self.present(alert, animated: true, completion: nil)
    }
}
