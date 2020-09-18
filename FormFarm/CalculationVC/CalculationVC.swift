//
//  CalculationVC.swift
//  FormFarm
//
//  Created by Studio Guatemala on 1/29/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit

protocol CalculationVCProtocol {
    func setCalculationDataToAnswer(line: FormModel, data: String)
}

class CalculationVC: UIViewController {

    var calculationVCProtocol: CalculationVCProtocol!
    var form: FormModel!
    var data = CalculationData()
    
    var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        transformAnswerToObject()
        
        initBackgroundColor()
        initNavBar()
        initTableView()
    }
    
    func initBackgroundColor() {
        if #available(iOS 13.0, *) {
            navigationController?.navigationBar.barTintColor = .secondarySystemBackground
            view.backgroundColor = .systemBackground
        } else {
            navigationController?.navigationBar.barTintColor = .white
            view.backgroundColor = .white
            
        }
    }
    
    func initTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.register(CalculationItemCell.self, forCellReuseIdentifier: "CalculationItemCell")
        tableView.pin(to: view)
    }
    
    func initNavBar() {
        setSaveButton()
        setTitle()
        setAddButton()
    }
    
    func setSaveButton() {
        let saveButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.save, target: self, action: #selector(CalculationVC.actionSaveButton))
        saveButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = saveButton
    }
    
    func setAddButton() {
        let addButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        addButton.setImage(UIImage(named: ImageNames.plusIcon.rawValue), for: .normal)
        addButton.imageView?.contentMode = .scaleAspectFit
        addButton.imageEdgeInsets = UIEdgeInsets.init(top: 7, left: 10, bottom: 7, right: 0)
        addButton.addTarget(self, action: #selector(actionAddButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addButton)
    }
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50, height: 50))
        titleLabel.text = form?.name
        if #available(iOS 13.0, *) { titleLabel.textColor = .label } else { titleLabel.textColor = .black }
        titleLabel.font = UIFont(name: FontName.montserratMedium.rawValue, size: 16.0)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        navigationItem.titleView = titleLabel
    }
    
    func encodeCalculationDataToJson() -> String {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(data)
        guard let json = String(data: jsonData, encoding: .utf8) else { return "" }
        return json
    }
    
    func decodeStringToCalculationData(data: Any) -> CalculationData {
        let jsonDecoder = JSONDecoder()
        let data = try! jsonDecoder.decode(CalculationData.self, from: data as! Data)
        return data
    }
    
    func transformAnswerToObject() {
        let value = form?.answer ?? ""
        if value.count > 0 {
            let info = Data(value.utf8)
            data = decodeStringToCalculationData(data: info)
        } else {
            data = CalculationData()
        }
    }
    
    func calculateTotalAmount() {
        var total: Double! = 0.00
        for item in data.items {
            total = total + Double(item.total ?? 0.00)
        }

        data.subtotal = total
        data.total = total
    }
    
    @objc func actionAddButton(sender: UIButton!) {
        showCalculateView(for: CalculationItem())
    }
    
    @objc func actionSaveButton(sender: UIButton!) {
        let string = encodeCalculationDataToJson()
        calculationVCProtocol.setCalculationDataToAnswer(line: form, data: string)
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK: - Calculation item VC:
extension CalculationVC: CalculationItemDelegate {
    func insertCalculateItem(item: Data) {
        let jsonDecoder = JSONDecoder()
        let item = try! jsonDecoder.decode(CalculationItem.self, from: item)
        self.data.items.append(item)
        self.calculateTotalAmount()
        self.tableView.reloadData()
    }

    func showCalculateView(for item: CalculationItem) {
        let calculationItemVC = CalculationItemVC()
        calculationItemVC.calculationItemDelegate = self
        calculationItemVC.item = item
        calculationItemVC.modalPresentationStyle = .popover
        let nav = UINavigationController(rootViewController: calculationItemVC)
        self.present(nav, animated: true, completion: nil)
    }
}
