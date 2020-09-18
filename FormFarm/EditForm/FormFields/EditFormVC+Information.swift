//
//  EditFormVC+Information.swift
//  FormFarm
//
//  Created by Studio Guatemala on 2/20/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit
import Foundation
import Eureka

protocol InformationProtocol {
    func createInformationSection(for line: FormModel) -> Section
}

extension EditFormVC: InformationProtocol {
    func createInformationSection(for line: FormModel) -> Section {
        return Section() <<< TextAreaRow() { row in
            row.disabled = true
        }.cellSetup({ (cell, row) in
            if #available(iOS 13.0, *) {
                if self.traitCollection.userInterfaceStyle == UIUserInterfaceStyle.light {
                    cell.backgroundColor = .secondarySystemBackground
                } else {
                    cell.backgroundColor = .systemBackground
                }
            } else {
                cell.backgroundColor = .white
            }

            cell.textView.textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping;
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }).cellUpdate({ (cell, row) in
            cell.textView.attributedText = line.details.htmlToAttributedString
            cell.textView.font = UIFont.systemFont(ofSize: 16)
            cell.textView.isScrollEnabled = false
            cell.textView.sizeToFit()
            let calculatedHeight = self.calculateHeight(text: line.details.htmlToAttributedString, font: UIFont.systemFont(ofSize: 16), width: self.view.frame.width * 0.8)
            cell.height = {
                return calculatedHeight
            }
            
            if #available(iOS 13.0, *) {
                cell.textView.textColor = .secondaryLabel
            } else {
                cell.textView.tintColor = .black
            }
        })
    }
    
    func calculateHeight (text: NSAttributedString?, font: UIFont, width: CGFloat) -> CGFloat {
        var currentHeight: CGFloat!
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        textView.attributedText = text
        textView.font = font
        textView.sizeToFit()
        
        currentHeight = textView.frame.height
        
        return currentHeight
    }
}

