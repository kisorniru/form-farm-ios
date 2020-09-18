//
//  EditFormVC+RadioSelect.swift
//  FormFarm
//
//  Created by a1 on 08.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol RadioSelectProtocol {
    func createRadio(for line: FormModel)
}

extension EditFormVC: RadioSelectProtocol {
    
    func createRadio(for line: FormModel) {
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView<UIView>(title: line.name)
            section.tag = line.slug
        }
        for option in line.values {
            form.last! <<< ImageCheckRow<String>("\(option)_\(line.slug)"){ lrow in
                lrow.title = option
                lrow.selectableValue = option
                if let answer = line.answer, answer == option {
                    lrow.value = answer
                    self.formFieldsForRequest[line.slug] = answer as AnyObject
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
    
    func setOnChange(for row: ImageCheckRow<String>, in line: FormModel) {
        if let value = row.value {
            updateAnswerInDB(for: line, with: value)
            formFieldsForRequest[line.slug] = value as AnyObject
            removeEmptyView(baseRow: row)
        } else {
            updateAnswerInDB(for: line, with: nil)
            formFieldsForRequest.removeValue(forKey: line.slug)
        }
    }
}
