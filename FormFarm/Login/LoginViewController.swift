//
//  LoginViewController.swift
//  FormFarm
//
//  Created by a1 on 22.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailLoginTextField: UITextField!
    @IBOutlet weak var passwordLoginTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let networkManager = NetworkManager.sharedInstance
    
    lazy var errorServerLoginHandler: (String) -> Void = { error in
        self.showErrorAlert(message: error)
        self.activityIndicator.stopAnimating()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        networkManager.checkNetworkConnect(network: networkManager) { isConnect in
            if !isConnect {
                self.showErrorInternetConnectionAlert()
            }
        }
    }
    
    @IBAction func logInActionBtn(_ sender: UIButton) {
        activityIndicator.startAnimating()
        view.endEditing(true)
        if emailLoginTextField.text != "" || passwordLoginTextField.text != "" {
            LibraryAPI.sharedInstance().postLoginDataToServer(email: emailLoginTextField.text!, password: passwordLoginTextField.text!, success: { responseLogin in
//                if let dataResponse = responseLogin["data"] as? [String: AnyObject] {
//                    self.initUserData(with: dataResponse)
//                }
                self.initHeader(with: responseLogin)
                LibraryAPI.sharedInstance().getAuthUserInfo(success: { response in
                    
                    self.initUserData(with: response)
                    self.activityIndicator.stopAnimating()
                    NavigationManager.goToMainView()
                }, failure: self.errorServerLoginHandler)
            }, failure: self.errorServerLoginHandler)
        } else {
            showErrorAlert(message: "Email and/or password field is empty!")
            activityIndicator.stopAnimating()
        }
    }
    
    func initUserData(with dataResponse: [String: AnyObject]) {
        let user = dataResponse["user"] as AnyObject
        let id = user["id"] as! Int
        let company = user["company"] as! String
        let email = user["email"] as! String
        let firstName = user["first_name"] as! String
        let secondName = user["last_name"] as! String
        UserManager.save(value: id, key: .id)
        UserManager.save(value: company, key: .company)
        UserManager.save(value: email, key: .email)
        UserManager.save(value: firstName, key: .firstName)
        UserManager.save(value: secondName, key: .secondName)
    }
    
    func initHeader(with authResponse: [String: AnyObject]) {
        let accessToken = authResponse["access_token"] as! String
        HeaderManager.save(value: accessToken, key: .accessToken)
    }
}
