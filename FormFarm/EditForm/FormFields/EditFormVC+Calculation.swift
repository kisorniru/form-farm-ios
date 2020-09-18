//
//  EditFormVC+Calculation.swift
//  FormFarm
//
//  Created by Studio Guatemala on 1/27/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import Foundation
import Eureka

protocol CalculationProtocol {
    func createCalculationButton(for line: FormModel) -> Section
}

extension EditFormVC: CalculationProtocol {
    func createCalculationButton(for line: FormModel) -> Section {
        return Section(line.name) <<< ButtonRow(line.slug) { row in
            row.cellStyle = .value1
            self.initCalculationRow(with: row, on: line)
        }.onCellSelection { cell, row in
            self.configCellSelection(for: cell, on: line)
        }
    }
        
    func initCalculationRow(with row: ButtonRow, on line: FormModel) {
        row.title = "Tap to add items" 
    }

    func configCellSelection(for cell: ButtonCellOf<String>, on line: FormModel) {
        showCalculationVC(for: line)
    }
}

extension EditFormVC: CalculationVCProtocol {
    func setCalculationDataToAnswer(line: FormModel, data: String) {
        self.formFieldsForRequest[line.slug] = data as AnyObject
        updateAnswerInDB(for: line, with: data)
    }
    
    func showCalculationVC(for line: FormModel) {
        let calculationVC = CalculationVC()
        calculationVC.calculationVCProtocol = self
        calculationVC.form = line
        navigationController?.pushViewController(calculationVC, animated: true)
    }
}
