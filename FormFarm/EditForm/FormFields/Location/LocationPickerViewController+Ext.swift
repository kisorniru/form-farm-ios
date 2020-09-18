//
//  LocationPickerViewController.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka
import LocationPicker
import CoreLocation
import MapKit

extension LocationPickerViewController {
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        configureBackButton()
        configureLocationWithoutInternet()
    }
    
    func configureLocationWithoutInternet() {
        NetworkManager.isUnreachable { _ in
            self.setLocationWithoutInternet(completion: { locationString in
                // self.completionString!(locationString)
                self.actionBackButton()
            })
        }
    }
    
    func setLocationWithoutInternet(completion: @escaping (_ location: String) -> Void) {
        let alert = UIAlertController(title: "No Internet connection!", message: "Write location:", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter here"
            textField.keyboardType = .default
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (_) in }))
        alert.addAction(UIAlertAction(title: "Accept", style: .default, handler: { [weak alert] (_) in
            guard let textField = alert?.textFields![0], let text = textField.text else { return }
            if !text.isEmpty {
                completion(text)
            } else {
                self.showErrorAlert(message: "Enter location or click Cancel")
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func configureBackButton() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        backButton.setImage(UIImage(named: ImageNames.formBackBtn.rawValue), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 5, left: 10, bottom: 5, right: 10)
        backButton.addTarget(self, action: #selector(LocationPickerViewController.actionBackButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc func actionBackButton() {
        navigationController?.navigationBar.barTintColor = UIColor(named: "main_green")
        navigationController?.popViewController(animated: false)
    }
}
