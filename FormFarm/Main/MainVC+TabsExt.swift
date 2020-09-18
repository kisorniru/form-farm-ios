//
//  MainVC+TabsExt.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

protocol TabsProtocol {
    func moveView(stopMoveButton: UIButton)
    func createUnderline(with widthSize: CGSize)
    func changeColorTitleBtn(stateMainTable: StateMainTable)
    func setTitleColorFor(allBtn: UIColor, draftBtn: UIColor, waitingBtn: UIColor)
}

extension MainVC: TabsProtocol {
    
    func moveView(stopMoveButton: UIButton) {
        UIView.animate(withDuration: 0.2) {
            self.underline.center.x = stopMoveButton.center.x
        }
    }
    
    func createUnderline(with widthSize: CGSize) {
        underline = UIView(frame: CGRect(x: 0, y: (allDocBtn.center.y + allDocBtn.frame.size.height/2), width: widthSize.width/3, height: 3))
        underline.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.4705882353, blue: 0.1254901961, alpha: 1)
        view.addSubview(underline)
    }
    
    func changeColorTitleBtn(stateMainTable: StateMainTable) {
        switch stateMainTable {
        case .allDocs:
            if #available(iOS 13.0, *) {
                setTitleColorFor(allBtn: .label, draftBtn: .secondaryLabel, waitingBtn: .secondaryLabel)
            } else {
                setTitleColorFor(allBtn: .black, draftBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1), waitingBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1))
            }
        case .draftDocs:
            if #available(iOS 13.0, *) {
                setTitleColorFor(allBtn: .secondaryLabel, draftBtn:.label, waitingBtn: .secondaryLabel)
            } else {
                setTitleColorFor(allBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1), draftBtn:.black, waitingBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1))
            }
        case .waitingDocs:
            if #available(iOS 13.0, *) {
                setTitleColorFor(allBtn: .secondaryLabel, draftBtn:.secondaryLabel, waitingBtn: .label)
            } else {
                setTitleColorFor(allBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1), draftBtn: #colorLiteral(red: 0.6899999976, green: 0.6899999976, blue: 0.6899999976, alpha: 1), waitingBtn: .black)
            }
        }
    }
    
    func setTitleColorFor(allBtn: UIColor, draftBtn: UIColor, waitingBtn: UIColor) {
        allDocBtn.setTitleColor(allBtn, for: .normal)
        draftDocBtn.setTitleColor(draftBtn, for: .normal)
        waitingDocBtn.setTitleColor(waitingBtn, for: .normal)
    }
}
