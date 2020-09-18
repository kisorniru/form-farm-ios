//
//  EditFormVC+TextField.swift
//  FormFarm
//
//  Created by a1 on 08.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol TextProtocol {
    func createTextField(for line: FormModel) -> Section
    func createTextAreaLine(for line: FormModel)
    func createTextInfoBlock(for line: FormModel)
    func createSpecialEmailField(for document: DocumentModel) -> BaseRow
    
    func textLine(for line: FormModel) -> TextRow
    func nameLine(for line: FormModel) -> NameRow
    func intLine(for line: FormModel) -> IntRow
    func decimalLine(for line: FormModel) -> DecimalRow
    func emailLine(for line: FormModel) -> EmailRow
    func phoneLine(for line: FormModel) -> PhoneRow
    func textAreaRow(for line: FormModel) -> TextAreaRow
}

extension EditFormVC: TextProtocol {
    
    func createTextField(for line: FormModel) -> Section {
        guard let textFieldType = TextFieldTypeNumber(rawValue: line.data_type.value!) else { return Section() }

        switch textFieldType {
        case .text:
            return Section(line.name) <<< textLine(for: line)
        case .name:
            return Section(line.name) <<< nameLine(for: line)
        case .int:
            return Section(line.name) <<< intLine(for: line)
        case .decimal:
            return Section(line.name) <<< decimalLine(for: line)
        case .email:
            return Section(line.name) <<< emailLine(for: line)
        case .phone:
            return Section(line.name) <<< phoneLine(for: line)
        }
    }
    
    func createTextAreaLine(for line: FormModel) {
        form +++ Section(line.name) <<< textAreaRow(for: line)
    }
    
    func createTextInfoBlock(for line: FormModel) {
        form +++ Section(line.name)
    }
    
    func createSpecialEmailField(for document: DocumentModel) -> BaseRow {
        return EmailRow("email_row") { row in
            if let answerEmail = document.emailForSend {
                row.value = answerEmail
                self.email = answerEmail
            } else {
                row.placeholder = "Enter your Email address here"
            }
        }.onChange { row in
            self.email = row.value ?? nil
            if let value = row.value {
                self.updateSpecialEmailInDB(with: value, in: document)
                for view in row.baseCell.subviews {
                    if let emptyView = view as? UIImageView {
                        emptyView.removeFromSuperview()
                    }
                }
            } else {
                self.updateSpecialEmailInDB(with: nil, in: document)
            }
        }
    }
    
    func textLine(for line: FormModel) -> TextRow {
        return TextRow(self, line).onChangeText(self, line)
    }
    
    func nameLine(for line: FormModel) -> NameRow {
        return NameRow(self, line).onChangeText(self, line)
    }
    
    func intLine(for line: FormModel) -> IntRow {
        return IntRow(line.slug) { row in
            if let answer = line.answer, let intAnswer = Int(string: answer) {
                row.value = intAnswer
                self.formFieldsForRequest[line.slug] = answer as AnyObject
                self.removeEmptyView(baseRow: row)
            } else {
                row.placeholder = line.placeholder
            }
        }.onChangeText(self, line)
    }
    
    func decimalLine(for line: FormModel) -> DecimalRow {
        return DecimalRow(line.slug) { row in
            if let answer = line.answer, let doubleAnswer = Double(string: answer) {
                row.value = doubleAnswer
                self.formFieldsForRequest[line.slug] = answer as AnyObject
                self.removeEmptyView(baseRow: row)
            } else {
                row.placeholder = line.placeholder
            }
        }.onChangeText(self, line)
    }
    
    func emailLine(for line: FormModel) -> EmailRow {
        return EmailRow(self, line).onChangeText(self, line)
    }
    
    func phoneLine(for line: FormModel) -> PhoneRow {
        return PhoneRow(self, line).onChangeText(self, line)
    }
    
    func textAreaRow(for line: FormModel) -> TextAreaRow {
        return TextAreaRow(self, line).onChangeText(self, line)
    }
    
}
