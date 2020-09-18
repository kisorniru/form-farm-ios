//
//  UIViewController+NetworkExt.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

protocol NetworkProtocol {
    func showErrorInternetConnectionAlert()
}

//MARK: - Network:
extension UIViewController: NetworkProtocol {
    
    func showErrorInternetConnectionAlert() {
        let alert = UIAlertController(title: "No internet connection!", message: "For the correct work of the application please connect to the Internet!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
