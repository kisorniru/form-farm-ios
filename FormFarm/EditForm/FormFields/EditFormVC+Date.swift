//
//  EditFormVC+Date.swift
//  FormFarm
//
//  Created by a1 on 08.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol DateProtocol {
    func createDateLine(for line: FormModel) -> Section
}

extension EditFormVC: DateProtocol {
    
    func createDateLine(for line: FormModel) -> Section {
        return Section(line.name) <<< DateRow(line.slug) { row in
            row.title = "Selected date"
            guard let dateType = DateTypeNumber(rawValue: line.date_type.value!) else { return }
            self.setDateFormat(for: row, with: dateType)
            if let answer = line.answer {
                row.value = row.dateFormatter?.date(from: answer)
            } else {
                row.value = Date()
            }
            self.updateDateValue(for: row, in: line)
        }.onCellSelection { (cell, row) in
            if row.value == nil {
                row.value = Date()// Set default value.
            }
        }.onChange { row in
            self.updateDateValue(for: row, in: line)
        }
    }
    
    func setDateFormat(for row: DateRow, with dateType: DateTypeNumber) {
        switch dateType {
        case .slashStyle:
            row.dateFormatter?.dateFormat = "MM/dd/yyyy"
        case .monthStyle:
            row.dateFormatter?.dateFormat = "MMMM yyyy"
        case .commaStyle:
            row.dateFormatter?.dateFormat = "MMM d, yyyy"
        case .dotStyle:
            row.dateFormatter?.dateFormat = "dd.MM.yy"
        }
    }
    
    func updateDateValue(for row: DateRow, in line: FormModel) {
        if let value = row.value {
            let stringValue = value.toString(dateFormat: "\(row.dateFormatter!.dateFormat!)")
            updateAnswerInDB(for: line, with: stringValue)
            formFieldsForRequest[line.slug] = stringValue as AnyObject
        }
    }
    
}
