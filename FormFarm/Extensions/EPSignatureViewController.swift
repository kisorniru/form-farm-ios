//
//  UIViewController+SignExt.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import EPSignature

//MARK: - Signature:
extension UIViewController: EPSignatureDelegate {
    
    func showSignatureView(for variable: String) {
        let signatureVC = EPSignatureViewController(signatureDelegate: self, showsDate: true, showsSaveSignatureOption: false)
        signatureVC.title = "\(UserManager.recieve(key: .firstName)) \(UserManager.recieve(key: .secondName))"
        signatureVC.variableSign = variable
        let value = UIInterfaceOrientation.landscapeLeft.rawValue
        UIDevice.current.setValue(value, forKey: "orientation")
        self.navigationController?.pushViewController(signatureVC, animated: true)
    }
}
