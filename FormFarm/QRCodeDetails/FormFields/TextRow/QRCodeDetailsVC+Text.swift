//
//  QRCodeDetailsVC+Text.swift
//  FormFarm
//
//  Created by Maria on 20.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol QRTextProtocol {
    func createTextField(for line: InfoModel) -> Section
    func createTextAreaLine(for line: InfoModel)
    func createTextInfoBlock(for line: InfoModel)
    
    func textLine(for line: InfoModel) -> TextRow
    func nameLine(for line: InfoModel) -> NameRow
    func intLine(for line: InfoModel) -> IntRow
    func decimalLine(for line: InfoModel) -> DecimalRow
    func emailLine(for line: InfoModel) -> EmailRow
    func phoneLine(for line: InfoModel) -> PhoneRow
    func textAreaRow(for line: InfoModel) -> TextAreaRow
}

extension QRCodeDetailsVC: QRTextProtocol {
    
    func createTextField(for line: InfoModel) -> Section {
        guard let textFieldType = TextFieldTypeNumber(rawValue: line.data_type.value!) else { return Section() }
        
        switch textFieldType {
        case .text:
            return Section(line.details) <<< textLine(for: line)
        case .name:
            return Section(line.details) <<< nameLine(for: line)
        case .int:
            return Section(line.details) <<< intLine(for: line)
        case .decimal:
            return Section(line.details) <<< decimalLine(for: line)
        case .email:
            return Section(line.details) <<< emailLine(for: line)
        case .phone:
            return Section(line.details) <<< phoneLine(for: line)
        }
    }
    
    func createTextAreaLine(for line: InfoModel) {
        form +++ Section(line.details) <<< textAreaRow(for: line)
    }
    
    func createTextInfoBlock(for line: InfoModel) {
        form +++ Section(line.details)
    }
    
    func textLine(for line: InfoModel) -> TextRow {
        return TextRow(self, line).onChangeText(self, line)
    }
    
    func nameLine(for line: InfoModel) -> NameRow {
        return NameRow(self, line).onChangeText(self, line)
    }
    
    func intLine(for line: InfoModel) -> IntRow {
        return IntRow(line.variable) { row in
                if let answer = line.answer, let intAnswer = Int(string: answer) {
                    row.value = intAnswer
                    self.formFieldsForRequest[line.variable] = answer as AnyObject
                    self.removeEmptyView(baseRow: row)
                } else {
                    row.placeholder = line.placeholder
                }
            }.onChangeText(self, line)
    }
    
    func decimalLine(for line: InfoModel) -> DecimalRow {
        return DecimalRow(line.variable) { row in
                if let answer = line.answer, let doubleAnswer = Double(string: answer) {
                    row.value = doubleAnswer
                    self.formFieldsForRequest[line.variable] = answer as AnyObject
                    self.removeEmptyView(baseRow: row)
                } else {
                    row.placeholder = line.placeholder
                }
            }.onChangeText(self, line)
    }
    
    func emailLine(for line: InfoModel) -> EmailRow {
        return EmailRow(self, line).onChangeText(self, line)
    }
    
    func phoneLine(for line: InfoModel) -> PhoneRow {
        return PhoneRow(self, line).onChangeText(self, line)
    }
    
    func textAreaRow(for line: InfoModel) -> TextAreaRow {
        return TextAreaRow(self, line).onChangeText(self, line)
    }
    
}
