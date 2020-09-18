//
//  QRCommonTextRow.swift
//  FormFarm
//
//  Created by Maria on 21.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol QRCommonTextRow: RowType {
    var placeholder: String? { get set }
    init(_ qrCodeDetailsVC: QRCodeDetailsVC, _ line: InfoModel)
    func onChangeText<Self: CommonTextRow>(_ qrCodeDetailsVC: QRCodeDetailsVC, _ line: InfoModel) -> Self
}

extension QRCommonTextRow where Self: BaseRow {
    
    init(_ qrCodeDetailsVC: QRCodeDetailsVC, _ line: InfoModel) {
        self.init(line.variable) { row in
            if let answer = line.answer as? Self.Cell.Value {
                row.value = answer
                qrCodeDetailsVC.formFieldsForRequest[line.variable] = answer as AnyObject
                qrCodeDetailsVC.removeEmptyView(baseRow: row)
            } else {
                row.placeholder = line.placeholder
            }
        }
    }
    
    func onChangeText<Self: CommonTextRow>(_ qrCodeDetailsVC: QRCodeDetailsVC, _ line: InfoModel) -> Self {
        return self.onChange({ row in
            if let value = row.value {
                qrCodeDetailsVC.updateAnswerInDB(for: line, with: "\(value)")
                qrCodeDetailsVC.formFieldsForRequest[line.variable] = value as AnyObject
                qrCodeDetailsVC.removeEmptyView(baseRow: row as BaseRow)
            } else {
                qrCodeDetailsVC.updateAnswerInDB(for: line, with: nil)
                qrCodeDetailsVC.formFieldsForRequest.removeValue(forKey: line.variable)
            }
        }) as! Self
    }
}

extension TextRow: QRCommonTextRow {}
extension NameRow: QRCommonTextRow {}
extension IntRow: QRCommonTextRow {}
extension DecimalRow: QRCommonTextRow {}
extension EmailRow: QRCommonTextRow {}
extension PhoneRow: QRCommonTextRow {}
extension TextAreaRow: QRCommonTextRow {}
