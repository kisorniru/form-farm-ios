//
//  QRCodeDetailsVC.swift
//  FormFarm
//
//  Created by Maria on 19.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import LocationPicker
import CoreLocation
import Eureka
import RealmSwift

class QRCodeDetailsVC: FormViewController {

    let realm = try! Realm()
    let locationManager = CLLocationManager()
    var location: Location?
    var editFormVC: EditFormVC?
    
    var companyName: String?
    var ppId: String?
    var currentAddress: String?
    //var servicingComp: String?
    var serviceInfo = [String: AnyObject]()
    var didSuccessSend: (() -> Void)?
    
    var selectedValues = [String: [String]]()
    var popoversSign = [String: PopoverSignatureVC]()
    var signaturesForServer = [String: UIImage]()
    var formFieldsForRequest = [String: AnyObject]()
    var fieldsFormVariables = [String]()
    var emptyImageView = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: 10.0, height: 10.0))
    
    var oldTableViewHight: CGFloat?
    
    var info: [InfoModel]? {
        didSet {
            initRows()
        }
    }
    
    lazy var reader = QRCodeReader()
    
    lazy var readerVC: QRCodeReaderViewController = {
        let readerVCBuilder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            $0.showTorchButton = true
            $0.preferredStatusBarStyle = .lightContent
            $0.reader.stopScanningWhenCodeIsFound = false
        }
        return QRCodeReaderViewController(builder: readerVCBuilder)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load")
        scanQRcode()
        getCurrentLocation()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor(named: "main_green")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let oldHight = oldTableViewHight {
            if oldHight > tableView.frame.size.height {
                var frame = tableView.frame
                frame.origin.y -= (oldHight-tableView.frame.size.height)
                frame.size.height += (oldHight-tableView.frame.size.height)
                tableView.frame = frame
                tableView.reloadData()
            }
        } else {
            oldTableViewHight = tableView.frame.height
        }
    }
    
    func initRows() {
        form.removeAll()
//        guard let info = info else { return }
//        form +++ Section("Company name:") <<< createCompanyNameRow()
//        form +++ Section("Porto Potty ID:") <<< createPortoPottyID()
//        form +++ Section("Location:") <<< createLocationRow()
        //form +++ Section("Servicing company:") <<< createServicingCompRow()
        
//        for line in info {
//            if line.input_type != 7 {
//                fieldsFormVariables.append(line.variable)
//            }
//            guard let formType = FormTypeNumber(rawValue: line.input_type) else { return }
//            switch formType {
//            case .textField:
//                form +++ createTextField(for: line)
//            case .textArea:
//                createTextAreaLine(for: line)
//            case .select:
//                createMultiSelect(for: line)
//            case .radio:
//                createRadio(for: line)
//            case .date:
//                form +++ createDateLine(for: line)
//            case .signature:
//                form +++ createSignatureBtn(for: line)
//            case .location:
//                form +++ createLocationBtn(for: line)
//            case .info:
//                createTextInfoBlock(for: line)
//            }
//        }
//        form +++ Section() <<< createSendBtn()
        form +++ Section() <<< createQRCodeScanBtn()
    }
    
    func createSendBtn() -> ButtonRow {
        return ButtonRow() { (row: ButtonRow) -> Void in
                    row.title = "SEND"
                }.cellSetup({ (cell, row) in
                    cell.tintColor = UIColor(named: "main_green")
                    cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                }).onCellSelection({ (cell, row) in
                    self.tapSendBtn()
                })
    }
    
    func tapSendBtn() {
        if isValidSendData() {
//            guard let servicingComp = self.servicingComp, !servicingComp.isEmpty else {
//                self.showErrorAlert(message: "Servicing company field can't be empty")
//                return
//            }
            let signatures = getSignsForServer()
            if isAllFieldsFilled() {
                NetworkManager.isUnreachable(completed: { _ in
                    self.showErrorAlert(message: "No internet connection. Connect to the Internet and try again.")
                })
                NetworkManager.isReachable(completed: { _ in
                    var imageData = [String: Data]()
                    for (key, value) in signatures {
                        imageData[key] = value.jpegData(compressionQuality: 0.5)
                    }
                    let parameters: [String: AnyObject] = [
                        "service_log": [
                            "company": self.companyName!,
                            "ppid": self.ppId!,
                            "location": self.currentAddress!,
                            //"servicing_company": servicingComp,
                            "info": self.formFieldsForRequest
                        ] as AnyObject
                    ]
                    self.sendServiceLogs(with: parameters, images: imageData)
                })
            }
        } else {
            self.showErrorAlert(message: "Required data not found. Please, rescan QR code")
        }
    }
    
    func sendServiceLogs(with parameters: [String: AnyObject], images: [String: Data]) {
        let spinner = displaySpinner(onView: view)
        LibraryAPI.sharedInstance().postServiceLogs(with: parameters, images: images, success: { successPost in
            self.removeSpinner(spinner: spinner)
            if successPost {
                let alert = UIAlertController(title: "Success", message: "Toilet marked as serviced", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                    self.didSuccessSend!()
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }) { error in
            self.removeSpinner(spinner: spinner)
            self.showErrorAlert(message: error)
        }
    }
    
    func createQRCodeScanBtn() -> ButtonRow {
        return ButtonRow() { row in
                    row.title = "SCAN QR CODE"
            }.cellSetup({ (cell, row) in
                cell.tintColor = .black
            }).onCellSelection({ (cell, row) in
                self.scanQRcode()
            })
    }
    
    func getSignsForServer() -> [String: UIImage] {
        for (_, value) in popoversSign {
            guard let line = value.infoLine else { continue }
            signaturesForServer[line.variable] = value.signatureImg
        }
        return signaturesForServer
    }
    
    func isAllFieldsFilled() -> Bool {
        let signaturesForServer = getSignsForServer()
        guard let info = info else { return false }
        
        if fieldsFormVariables.count != (signaturesForServer.count != 0 ? formFieldsForRequest.count + signaturesForServer.count : formFieldsForRequest.count) {
            var emptyFields = [String]()
            for (index, field) in fieldsFormVariables.enumerated() {
                if formFieldsForRequest[field] == nil && signaturesForServer[field] == nil, info[index].required {
                    emptyFields.append(field)
                }
            }
            if emptyFields.count != 0 {
                let alert = UIAlertController(title: "Error", message: "Some fields are empty, please fill the required fields!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.setMarkers(for: emptyFields)
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    func setMarkers(for emptyFields: [String]) {
        for field in emptyFields {
            let emptyImageView = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: 10.0, height: 10.0))
            emptyImageView.image = UIImage(named: ImageNames.emptyField.rawValue)
            if let row = self.form.rowBy(tag: field) {
                row.baseCell.addSubview(emptyImageView)
                row.updateCell()
            } else {
                let emptyImageView = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: 10.0, height: 10.0))
                emptyImageView.image = UIImage(named: ImageNames.emptyField.rawValue)
                if let section = self.form.sectionBy(tag: field) {
                    section.first?.baseCell.addSubview(emptyImageView)
                    section.reload()
                }
            }
        }
    }
    
    func isValidSendData() -> Bool {
        guard let company = companyName, !company.isEmpty else { return false }
        guard let ppid = ppId, !ppid.isEmpty else { return false }
        guard let location = currentAddress, !location.isEmpty else { return false }
        return true
    }
    
    func updateAnswerInDB(for line: InfoModel, with text: String?) {
        try! realm.write {
            line.answer = text
        }
    }
    
    func removeEmptyView(baseRow: BaseRow) {
        for view in baseRow.baseCell.subviews {
            if let emptyView = view as? UIImageView {
                emptyView.removeFromSuperview()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("----------------- PREPARE -----------------")
        if segue.identifier == IdentifierSegue.locationSegue.rawValue {
            if let senderBaseRow = sender as? BaseRow {
                guard let locationVariable = senderBaseRow.tag else { return }
                guard let locationPicker = segue.destination as? LocationPickerViewController else { return }
                if let locationLines = self.info?.filter({ $0.variable == locationVariable }), let locationLine = locationLines.first {
                    self.setLocationDescriptions(for: locationPicker, line: locationLine)
                }
            }
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
