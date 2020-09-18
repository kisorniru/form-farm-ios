//
//  QRCodeDetailsVC+StaticFieldsExt.swift
//  FormFarm
//
//  Created by Maria on 20.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka

extension QRCodeDetailsVC {
    
    func createCompanyNameRow() -> BaseRow {
        return TextRow("company_name_row") { row in
            row.value = ""
            }.cellSetup({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.adjustsFontSizeToFitWidth = true
                cell.textField.minimumFontSize = 6
            }).cellUpdate({ (cell, row) in
                row.value = self.companyName != nil ? self.companyName : ""
            })
    }
    
    func createPortoPottyID() -> BaseRow {
        return TextRow("ppid_row") { row in
            row.value = ""
            }.cellSetup({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.adjustsFontSizeToFitWidth = true
                cell.textField.minimumFontSize = 6
            }).cellUpdate({ (cell, row) in
                row.value = self.ppId != nil ? self.ppId : ""
            })
    }
    
    func createLocationRow() -> BaseRow {
        return TextRow("location_row") { row in
            row.value = ""
            }.cellSetup({ (cell, row) in
                cell.isUserInteractionEnabled = false
                cell.textField.adjustsFontSizeToFitWidth = true
                cell.textField.minimumFontSize = 9
            }).cellUpdate({ (cell, row) in
                row.value = self.currentAddress != nil ? self.currentAddress : ""
            })
    }
    
//    func createServicingCompRow() -> BaseRow {
//        return TextRow("servicing_row") { row in
//            row.placeholder = "Enter here"
//            }.onChange({ row in
//                if let company = row.value, !company.isEmpty {
//                    self.servicingComp = company
//                }
//            })
//    }
}
