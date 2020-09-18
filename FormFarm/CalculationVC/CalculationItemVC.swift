//
//  CalculationItemVC.swift
//  FormFarm
//
//  Created by Studio Guatemala on 1/30/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit
import Eureka

protocol CalculationItemDelegate {
    func insertCalculateItem(item: Data)
}

class CalculationItemVC: FormViewController {
    
    var calculationItemDelegate: CalculationItemDelegate!
    var tintColor: UIColor?
    var item: CalculationItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            view.backgroundColor = .secondarySystemBackground
            tintColor = .secondaryLabel
        } else {
            view.backgroundColor = .white
            tintColor = .black
        }

        initNavBar()
        initForms()
    }
    
    func initNavBar() {
        setCancelButton()
        setSaveButton()
    }
    
    func initForms() {
        form +++ Section()
            <<< TextAreaRow() { row in
                row.tag = "description"
                row.title = "Description"
                row.placeholder = "Enter description here"
                row.baseValue = self.item?.description ?? ""
            }.onChange { row in
                self.item?.description = row.value
            }
            <<< DecimalRow() { row in
                row.tag = "quantity"
                row.title = "Quantity"
                row.placeholder = "0.00"
                row.value = self.item?.quantity
                row.useFormatterOnDidBeginEditing = true
            }.onChange { row in
                self.item?.quantity = row.value
                self.calculateItemTotal()
            }
            <<< DecimalRow() { row in
                row.tag = "price"
                row.title = "Price"
                row.placeholder = "0.00"
                row.value = self.item?.price
                row.useFormatterOnDidBeginEditing = true
            }.onChange { row in
                self.item?.price = row.value
                self.calculateItemTotal()
            }
        form +++ Section()
            <<< DecimalRow() { row in
                row.tag = "total"
                row.disabled = true
                row.title = "Total"
                row.placeholder = "0.00"
                row.value = self.item?.total
                row.useFormatterOnDidBeginEditing = true
            }
    }
    
    func setCancelButton() {
        let cancelButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(CalculationItemVC.onTouchCancelButton))
        cancelButton.tintColor = tintColor
        self.navigationItem.leftBarButtonItem = cancelButton
    }
    
    func setSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(CalculationItemVC.onTouchSaveButton))
        saveButton.tintColor = tintColor
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    // MARK: - Button Actions
    
    @objc func onTouchCancelButton() {
        dismiss(animated: true, completion: nil)
    }

    @objc func onTouchSaveButton() {
        let dataItem = Data(encodeItemToString().utf8)
        calculationItemDelegate.insertCalculateItem(item: dataItem)
        dismiss(animated: true, completion: nil)
    }
    
    func calculateItemTotal() {
        let row: DecimalRow? = form.rowBy(tag: "total")
        let total = Double(self.item?.quantity ?? 0.00) * Double(self.item?.price ?? 0.00)
        self.item?.total = total
        row?.value = total
        row?.updateCell()
    }
    
    func encodeItemToString() -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(self.item)
        guard let json = String(data: jsonData, encoding: .utf8) else { return "" }
        return json
    }

}
