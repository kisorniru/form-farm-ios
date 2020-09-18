//
//  QRCodeDetailsVC+RadioSelect.swift
//  FormFarm
//
//  Created by Maria on 21.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol QRRadioSelectProtocol {
    func createRadio(for line: InfoModel)
}

extension QRCodeDetailsVC: QRRadioSelectProtocol {
    
    func createRadio(for line: InfoModel) {
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView<UIView>(title: line.details)
            section.tag = line.variable
        }
        for option in line.values {
            form.last! <<< ImageCheckRow<String>("\(option)_\(line.variable)"){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                if let answer = line.answer, answer == option {
                    lrow.value = answer
                    self.formFieldsForRequest[line.variable] = answer as AnyObject
                } else {
                    lrow.value = nil
                }
                }.onChange{ row in
                    self.setOnChange(for: row, in: line)
                }.cellSetup({ cell, _ in
                    cell.textLabel?.numberOfLines = 3
                    cell.textLabel?.adjustsFontSizeToFitWidth = true
                    cell.textLabel?.minimumScaleFactor = 0.5
                })
        }
    }
    
    func setOnChange(for row: ImageCheckRow<String>, in line: InfoModel) {
        if let value = row.value {
            updateAnswerInDB(for: line, with: value)
            formFieldsForRequest[line.variable] = value as AnyObject
            removeEmptyView(baseRow: row)
        } else {
            updateAnswerInDB(for: line, with: nil)
            formFieldsForRequest.removeValue(forKey: line.variable)
        }
    }
}

