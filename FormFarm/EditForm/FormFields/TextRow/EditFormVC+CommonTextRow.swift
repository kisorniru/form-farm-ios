//
//  EditFormVC+CommonTextRow.swift
//  FormFarm
//
//  Created by Maria on 21.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol CommonTextRow: RowType {
    var placeholder: String? { get set }
    init(_ editFromVC: EditFormVC, _ line: FormModel)
    func onChangeText<Self: CommonTextRow>(_ editFromVC: EditFormVC, _ line: FormModel) -> Self
}

extension CommonTextRow where Self: BaseRow {
    
    init(_ editFromVC: EditFormVC, _ line: FormModel) {
        self.init(line.slug) { row in
            if let answer = line.answer as? Self.Cell.Value {
                row.value = answer
                editFromVC.formFieldsForRequest[line.slug] = answer as AnyObject
                editFromVC.removeEmptyView(baseRow: row)
            } else {
                row.placeholder = line.placeholder
            }
        }
    }
    
    func onChangeText<Self: CommonTextRow>(_ editFromVC: EditFormVC, _ line: FormModel) -> Self {
        return self.onChange({ row in
            if let value = row.value {
                editFromVC.updateAnswerInDB(for: line, with: "\(value)")
                editFromVC.formFieldsForRequest[line.slug] = value as AnyObject
                editFromVC.removeEmptyView(baseRow: row as BaseRow)
            } else {
                editFromVC.updateAnswerInDB(for: line, with: nil)
                editFromVC.formFieldsForRequest.removeValue(forKey: line.slug)
            }
        }) as! Self
    }
}

extension TextRow: CommonTextRow {}
extension NameRow: CommonTextRow {}
extension IntRow: CommonTextRow {}
extension DecimalRow: CommonTextRow {}
extension EmailRow: CommonTextRow {}
extension PhoneRow: CommonTextRow {}
extension TextAreaRow: CommonTextRow {}
