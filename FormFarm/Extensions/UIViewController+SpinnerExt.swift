//
//  UIViewController+SpinnerExt.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

protocol SpinnerProtocol {
    func displaySpinner(onView: UIView) -> UIView
    func removeSpinner(spinner: UIView)
}

//MARK: - Spinner:
extension UIViewController: SpinnerProtocol {
    
    func displaySpinner(onView: UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        return spinnerView
    }
    
    func removeSpinner(spinner: UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
