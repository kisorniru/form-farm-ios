//
//  QRCodeDetailsVC+Select.swift
//  FormFarm
//
//  Created by Maria on 21.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol QRSelectProtocol {
    func createMultiSelect(for line: InfoModel)
    func convertArrayToJsonString(array: [String]) -> String
}

extension QRCodeDetailsVC: QRSelectProtocol {
    
    func createMultiSelect(for line: InfoModel) {
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView<UIView>(title: line.details)
            section.tag = line.variable
            section.selectionType = .multipleSelection
        }
        for option in line.values {
            form.last! <<< ImageCheckRow<String>("\(option)_\(line.variable)"){ lrow in
                self.initRow(with: option, line, lrow)
                }.cellSetup { cell, _ in
                    self.setCellSetup(cell)
                }.onChange { row in
                    self.setOnChange(for: row, on: line)
            }
        }
    }
    
    func initRow(with option: String, _ line: InfoModel, _ row: ImageCheckRow<String>) {
        row.title = option
        row.selectableValue = option
        if let answer = line.answer {
            let answerArr = answer.components(separatedBy: "-//-")
            selectedValues[line.variable] = answerArr
            formFieldsForRequest[line.variable] = answer as AnyObject
            for answer in answerArr {
                if answer == option {
                    row.value = answer
                }
            }
        } else {
            row.value = nil
        }
    }
    
    func setCellSetup(_ cell: ImageCheckCell<String>) {
        cell.trueImage = UIImage(named: ImageNames.selectMultiChecked.rawValue)!
        cell.falseImage = UIImage(named: ImageNames.selectMultiUnchecked.rawValue)!
        cell.accessoryType = .checkmark
        cell.textLabel?.numberOfLines = 2
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        cell.textLabel?.minimumScaleFactor = 0.5
    }
    
    func setOnChange(for row: ImageCheckRow<String>, on line: InfoModel) {
        var newSelectedValues = [String]()
        if let value = row.value {
            if var oldSelectedValues = selectedValues[line.variable], !oldSelectedValues.contains(value) {
                oldSelectedValues.append(value)
                selectedValues[line.variable] = oldSelectedValues
                newSelectedValues = oldSelectedValues
            } else {
                newSelectedValues.append(value)
                selectedValues[line.variable] = newSelectedValues
            }
            setValues(newSelectedValues, line, row)
        } else {
            guard var newSelectedValues = selectedValues[line.variable] else { return }
            let indexOfUnselectedValue = newSelectedValues.index(of: row.selectableValue!)
            newSelectedValues.remove(at: indexOfUnselectedValue!)
            selectedValues[line.variable]?.remove(at: indexOfUnselectedValue!)
            setValues(newSelectedValues, line, row)
        }
    }
    
    func setValues(_ selectedValues: [String], _ line: InfoModel, _ row: ImageCheckRow<String>) {
        let jsonString = convertArrayToJsonString(array: selectedValues)
        if jsonString != "[]" {
            let answerString = selectedValues.compactMap({$0}).joined(separator: "-//-")
            updateAnswerInDB(for: line, with: answerString)
            formFieldsForRequest[line.variable] = jsonString as AnyObject
            removeEmptyView(baseRow: row)
        } else {
            updateAnswerInDB(for: line, with: nil)
            formFieldsForRequest.removeValue(forKey: line.variable)
        }
    }
    
    func convertArrayToJsonString(array: [String]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: []) else { return "" }
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}

