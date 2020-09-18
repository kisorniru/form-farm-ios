//
//  NSObject + Alert.swift
//  FormFarm
//
//  Created by Maria on 01/04/2019.
//  Copyright © 2019 fruktorum. All rights reserved.
//

import Foundation
import UIKit

extension NSObject {
    
    func showError(message: String, without spinner: UIView? = nil) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            if let spinner = spinner {
                topController.removeSpinner(spinner: spinner)
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
}
