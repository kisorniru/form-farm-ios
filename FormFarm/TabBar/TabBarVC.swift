//
//  TabBarVC.swift
//  FormFarm
//
//  Created by Maria on 20.08.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit

class TabBarVC: UIViewController, UIPopoverPresentationControllerDelegate {

    @IBOutlet weak var nameBarButton: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet var buttons: [UIButton]!
    
    var mainVC: MainVC!
    var qrCodeDetailsVC: QRCodeDetailsVC!
    var viewControllers: [UIViewController]!
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsForNavigationBar()
        configureTabBarNavigation()
    }
    
    func settingsForNavigationBar() {
//        navigationController?.navigationBar.isTranslucent = false
//        navigationController?.toolbar.isTranslucent = false
        nameBarButton.setTitle("\(UserManager.recieve(key: .firstName)) \(UserManager.recieve(key: .secondName))", for: .normal)
        logoutBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        logoutBtn.setImage(UIImage(named: ImageNames.logoutIcon.rawValue), for: .normal)
    }
    
    func configureTabBarNavigation() {
        let storyboard = UIStoryboard(name: StoryboardNames.main.rawValue, bundle: nil)
        mainVC = storyboard.instantiateViewController(withIdentifier: IdentifierVC.main.rawValue) as! MainVC
        qrCodeDetailsVC = storyboard.instantiateViewController(withIdentifier: IdentifierVC.qrCodeDetailsVC.rawValue) as! QRCodeDetailsVC
        qrCodeDetailsVC.didSuccessSend = {
            self.selectedIndex = 0
            self.viewDidLoad()
        }
        viewControllers = [mainVC, qrCodeDetailsVC]
        buttons[selectedIndex].isSelected = true
        pressTabBarBtn(buttons[selectedIndex])
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        let popoverLogoutVC = storyboard?.instantiateViewController(withIdentifier: IdentifierVC.popoverLogout.rawValue) as! PopoverLogoutVC
        popoverLogoutVC.preferredContentSize = CGSize(width: 110, height: 70)
        popoverLogoutVC.modalPresentationStyle = UIModalPresentationStyle.popover
        guard let popover = popoverLogoutVC.popoverPresentationController else { return }
        popover.delegate = self
        popover.sourceView = sender as? UIButton
        popover.sourceRect = (popover.sourceView?.bounds)!
        present(popoverLogoutVC, animated: true, completion: nil)
    }
    
    @IBAction func pressTabBarBtn(_ sender: UIButton) {
        animateTabBar()
        clearPreviousVC(by: sender)
        setCurrentVC(by: sender)
    }
    
    func animateTabBar() {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        contentView.layer.add(transition, forKey: nil)
    }
    
    func clearPreviousVC(by button: UIButton) {
        let previousIndex = selectedIndex
        selectedIndex = button.tag
        buttons[previousIndex].isSelected = false
        let previousVC = viewControllers[previousIndex]
        previousVC.willMove(toParent: nil)
        previousVC.view.removeFromSuperview()
        previousVC.removeFromParent()
    }
    
    func setCurrentVC(by button: UIButton) {
        button.isSelected = true
        let currentVC = viewControllers[selectedIndex]
        //Calls the viewWillAppear method of the ViewController you are adding:
        addChild(currentVC)
        currentVC.view.frame = contentView.bounds
        contentView.addSubview(currentVC.view)
        //Call the viewDidAppear method of the ViewController you are adding:
        currentVC.didMove(toParent: self)
        
        switch currentVC {
        case mainVC:
            configTabBarButtons(with: selectedIndex, selectTextImage: ImageNames.docIconActive.rawValue)
        case qrCodeDetailsVC:
            configTabBarButtons(with: selectedIndex, selectTextImage: ImageNames.qrCodeActive.rawValue)
        default:
            configTabBarButtons(with: selectedIndex, selectTextImage: ImageNames.docIconActive.rawValue)
        }
    }
    
    func configTabBarButtons(with selectedIndex: Int, selectTextImage: String) {
        buttons[0].setImage(UIImage(named: ImageNames.docIcon.rawValue), for: .normal)
        buttons[1].setImage(UIImage(named: ImageNames.qrCode.rawValue), for: .normal)
        for index in 0...1 {
            if index == selectedIndex {
                buttons[selectedIndex].setImage(UIImage(named: selectTextImage), for: .normal)
            }
        }
    }

}
