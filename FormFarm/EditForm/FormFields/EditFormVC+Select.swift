//
//  EditFormVC+Select.swift
//  FormFarm
//
//  Created by a1 on 08.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol SelectProtocol {
    func createMultiSelect(for line: FormModel)
    func convertArrayToJsonString(array: [String]) -> String
}

extension EditFormVC: SelectProtocol {
    
    func createMultiSelect(for line: FormModel) {
        form +++ SelectableSection<ImageCheckRow<String>>() { section in
            section.header = HeaderFooterView<UIView>(title: line.name)
            section.tag = line.slug
            section.selectionType = .multipleSelection
        }
        for option in line.values {
            form.last! <<< ImageCheckRow<String>("\(option)_\(line.slug)"){ lrow in
                self.initRow(with: option, line, lrow)
            }.cellSetup { cell, _ in
                self.setCellSetup(cell)
            }.onChange { row in
                self.setOnChange(for: row, on: line)
            }
        }
    }
    
    func initRow(with option: String, _ line: FormModel, _ row: ImageCheckRow<String>) {
        row.title = option
        row.selectableValue = option
        if let answer = line.answer {
            let answerArr = answer.components(separatedBy: ",")
            selectedValues[line.slug] = answerArr
            formFieldsForRequest[line.slug] = answer as AnyObject
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
    
    func setOnChange(for row: ImageCheckRow<String>, on line: FormModel) {
        var newSelectedValues = [String]()
        if let value = row.value {
            if var oldSelectedValues = selectedValues[line.slug], !oldSelectedValues.contains(value) {
                oldSelectedValues.append(value)
                selectedValues[line.slug] = oldSelectedValues
                newSelectedValues = oldSelectedValues
            } else {
                newSelectedValues.append(value)
                selectedValues[line.slug] = newSelectedValues
            }
            setValues(newSelectedValues, line, row)
        } else {
            guard var newSelectedValues = selectedValues[line.slug] else { return }
            let indexOfUnselectedValue = newSelectedValues.index(of: row.selectableValue!)
            newSelectedValues.remove(at: indexOfUnselectedValue!)
            selectedValues[line.slug]?.remove(at: indexOfUnselectedValue!)
            setValues(newSelectedValues, line, row)
        }
    }
    
    func setValues(_ selectedValues: [String], _ line: FormModel, _ row: ImageCheckRow<String>) {
        let jsonString = convertArrayToJsonString(array: selectedValues)
        if jsonString != "[]" {
//            let answerString = selectedValues.compactMap({$0}).joined(separator: "-//-")
            let answerString = selectedValues.compactMap({$0}).joined(separator: ",")
            updateAnswerInDB(for: line, with: answerString)
            formFieldsForRequest[line.slug] = answerString as AnyObject
            removeEmptyView(baseRow: row)
        } else {
            updateAnswerInDB(for: line, with: nil)
            formFieldsForRequest.removeValue(forKey: line.slug)
        }
    }
    
    func convertArrayToJsonString(array: [String]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: array, options: []) else { return "" }
        return String(data: data, encoding: String.Encoding.utf8)!
    }
}
