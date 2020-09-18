//
//  EditFormVC.swift
//  FormFarm
//
//  Created by a1 on 23.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import UIKit
import Eureka
import QuickLook
import EPSignature
import LocationPicker
import CoreLocation
import MapKit
import RealmSwift

class EditFormVC: FormViewController {
    
    let realm = try! Realm()
    var startDocumentTitle: String?
    var finalItems = [PreviewItemModel(nil, nil)]
    var email: String?
    var selectedValues = [String: [String]]()
    var popoversSign = [String: PopoverSignatureVC]()
    var signaturesForServer = [String: UIImage]()
    var formFieldsForRequest = [String: AnyObject]()
    var fieldsFormVariables = [String]()
    var emptyImageView = UIImageView(frame: CGRect(x: 5.0, y: 5.0, width: 10.0, height: 10.0))
    var location: Location?
    var isIPhoneX = false
    var currentAddress = ""
    
    let realmManager = RealmManager()
    let networkManager = NetworkManager.sharedInstance
    let locationManager = CLLocationManager()
    
    @IBOutlet weak var previewBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    var oldTableViewHight: CGFloat?
    
    var selectDocument: DocumentModel? {
        didSet {
            guard let selectDoc = selectDocument else { return }
            if selectDoc.isDraft {
                recievedFormsFromDB(for: selectDoc)
            } else {
                NetworkManager.isUnreachable { _ in
                    self.recievedFormsFromDB(for: selectDoc)
                }
                NetworkManager.isReachable { _ in
                    self.recievedFormsFromServer(for: selectDoc)
                }
            }
        }
    }
    
    var forms: [FormModel]? {
        didSet {
            initForms()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isIPhoneX = ((view.frame.size.height != 812) && (view.frame.size.height != 896)) ? false : true
        initNavBar()
        setTableViewFrame()
        getCurrentLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .default
        
        if selectDocument?.isSubmitted == true {
            sendBtn.isHidden = true
            previewBtn.isHidden = true
        }
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
    
    func initNavBar() {
        location = nil
        //background color of nav bar
        if #available(iOS 13.0, *) {
            self.navigationController?.navigationBar.barTintColor = .secondarySystemBackground
        } else {
            self.navigationController?.navigationBar.barTintColor = .white
        }
        setTitle()
        setBackBtn()
        if selectDocument?.isSubmitted == false {
            setTrashBtn()
        }
    }
    
    func setTitle() {
        let titleLabel = UILabel(frame: CGRect(x: 0.0, y: 0.0, width: 50, height: 50))
        titleLabel.text = startDocumentTitle
        if #available(iOS 13.0, *) {
            titleLabel.textColor = .label
        } else {
            titleLabel.textColor = .black
        }
        titleLabel.font = UIFont(name: FontName.montserratMedium.rawValue, size: 19.0)
        titleLabel.numberOfLines = 2
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        navigationItem.titleView = titleLabel
    }
    
    func setBackBtn() {
        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        backButton.setImage(UIImage(named: ImageNames.formBackBtn.rawValue), for: .normal)
        backButton.contentMode = .scaleAspectFit
        backButton.imageEdgeInsets = UIEdgeInsets.init(top: 4, left: 0, bottom: 4, right: 10)
        backButton.addTarget(self, action: #selector(EditFormVC.actionBackButton), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func setTrashBtn() {
        let trashButton = UIButton(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        trashButton.setImage(UIImage(named: ImageNames.trashBtn.rawValue), for: .normal)
        trashButton.imageView?.contentMode = .scaleAspectFit
        trashButton.imageEdgeInsets = UIEdgeInsets.init(top: 7, left: 10, bottom: 7, right: 0)
        trashButton.addTarget(self, action: #selector(actionTrashButton), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: trashButton)
    }
    
    func setTableViewFrame() {
        //set frame for form table view
        var frame = tableView.frame
        frame.size.height -= isIPhoneX ? 80 : 46
        tableView.frame = frame
    }
    
    func recievedFormsFromServer(for selectDocument: DocumentModel) {
        LibraryAPI.sharedInstance().getFormsFromServer(for: selectDocument, success: { formsFromServer in
            self.forms = formsFromServer
            if selectDocument.isSubmitted == false {
                DispatchQueue.main.async {
                    try! self.realm.write {
                        selectDocument.isDraft = true
                    }
                }
            }
        }) { error in
            self.showErrorAlert(message: error)
        }
    }
    
    func recievedFormsFromDB(for selectDocument: DocumentModel) {
        LibraryAPI.sharedInstance().getFormsFromDB(for: selectDocument, success: { formsFromDB in
            self.forms = formsFromDB
            if selectDocument.isSubmitted == false {
                DispatchQueue.main.async {
                    try! self.realm.write {
                        selectDocument.isDraft = true
                    }
                }
            }
        }) { error in
            self.showErrorAlert(message: error)
        }
    }
    
    @objc func actionBackButton() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func actionTrashButton(sender: UIButton!) {
        guard let selectDoc = selectDocument else { return }
        if selectDoc.isDraft {
            configDraft(for: selectDoc)
        }
        if selectDoc.isWaiting {
            configWaiting(for: selectDoc)
        }
        actionBackButton()
    }
    
    func configDraft(for selectDoc: DocumentModel) {
        if selectDoc.isDraft {
            LibraryAPI.sharedInstance().removeDocumentInServer(for: selectDoc, success: { removed in
                try! self.realm.write {
                    selectDoc.isDraft = false
                    selectDoc.emailForSend = nil
                }
                
                return
            }) { error in
                print(error)
                self.showErrorAlert(message: "The document \"\(selectDoc.name)\" cannot be removed")
            }
        }
    }
    
    func configWaiting(for selectDoc: DocumentModel) {
        try! self.realm.write {
            selectDoc.isWaiting = false
            selectDoc.emailForSend = nil
            guard let forms = forms else { return }
            for form in forms {
                form.answer = nil
                form.answerImage = nil
            }
        }
    }
    
    func initForms() {
        guard forms != nil else { return }
        
        for line in forms! {
            if line.disabled {
                continue
            }

            fieldsFormVariables.append(line.slug)
            guard let formType = FormTypeNumber(rawValue: line.input_type) else { return }
            switch formType {
            case .textField:
                form +++ createTextField(for: line)
            case .textArea:
                createTextAreaLine(for: line)
            case .select:
                createMultiSelect(for: line)
            case .radio:
                createRadio(for: line)
            case .date:
                form +++ createDateLine(for: line)
            case .signature:
                form +++ createSignatureBtn(for: line)
            case .location:
                form +++ createLocationBtn(for: line)
            case .info:
                form +++ createInformationSection(for: line)
            case .calculation:
                form +++ createCalculationButton(for: line)
            case .ticket_id:
                form +++ createTicketIDRow(for: line)
            }
        }
        if selectDocument?.isSubmitted == false {
            if let selectDoc = selectDocument {
                form +++ Section("Email where the document will be sent") <<< createSpecialEmailField(for: selectDoc)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == IdentifierSegue.locationSegue.rawValue {
            if let senderBaseRow = sender as? BaseRow {
                guard let locationVariable = senderBaseRow.tag else { return }
                guard let locationPicker = segue.destination as? LocationPickerViewController else { return }
                if let locationLines = self.forms?.filter({ $0.slug == locationVariable }), let locationLine = locationLines.first {
                    self.setLocationDescriptions(for: locationPicker, line: locationLine)
                }
            }
        }
    }
    
    func getSignsForServer() -> [String: UIImage] {
        for (_, value) in popoversSign {
            guard let line = value.line else { continue }
            signaturesForServer[line.slug] = value.signatureImg
        }
        return signaturesForServer
    }
    
    func isAllFieldsFilled(isNeedEmail: Bool) -> Bool {
        let signaturesForServer = getSignsForServer()
        guard let forms = forms else { return false }
        
        if fieldsFormVariables.count != (signaturesForServer.count != 0 ? formFieldsForRequest.count + signaturesForServer.count : formFieldsForRequest.count) {
            var emptyFields = [String]()
            for (index, field) in fieldsFormVariables.enumerated() {
                if formFieldsForRequest[field] == nil && signaturesForServer[field] == nil, forms[index].required {
                    emptyFields.append(field)
                }
            }
            if emptyFields.count != 0 {
                let alert = UIAlertController(title: "Error", message: "Some fields are empty, please fill the required fields!", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                    if isNeedEmail {
                        if self.email == nil {
                            emptyFields.append("email_row")
                        }
                    }
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
    
    @IBAction func actionSendBtn(_ sender: Any) {
        if isAllFieldsFilled(isNeedEmail: true) {
            guard let document = selectDocument else { return }
            let signatures = getSignsForServer()
            guard let email = email else {
                showErrorAlert(message: "Field with Email address is empty! Please enter your Email")
                return
            }
            if email.contains("@") && email.contains(".") {
                NetworkManager.isUnreachable(completed: { _ in
                    self.createWaitForm(to: email, for: document, with: signatures)
                })
                NetworkManager.isReachable(completed: { _ in
                    self.showSendMessage(to: email, for: document, with: signatures)
                })
            } else {
                showErrorAlert(message: "You enter incorrect Email address!")
            }
        }
    }
    
    func createWaitForm(to email: String, for document: DocumentModel, with signatures: [String : UIImage]) {
        let formWait = FormWaitModel()
        formWait.documentId = document.id
        formWait.email = email
        for fields in formFieldsForRequest {
            let requestField = RequestField()
            requestField.key = fields.key
            requestField.value = fields.value as? String
            formWait.requestFields.append(requestField)
        }
        for signature in signatures {
            let sign = Sign()
            sign.key = signature.key
            sign.value = signature.value.jpegData(compressionQuality: 0.5)
            formWait.signs.append(sign)
        }
        realmManager.writeWaitFormsToRealm(formWait)
        try! realm.write {
            document.isWaiting = true
            document.isDraft = false
        }
        showErrorAlert(message: "No internet connection! Your document will be sent when the device connects to the Internet")
    }
    
    func showSendMessage(to email: String, for document: DocumentModel, with sign: [String: UIImage]) {
        let alert = UIAlertController(title: "Send to Email:", message: "\(email)?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            self.sendDoc(to: email, for: document, with: sign)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func sendDoc(to email: String, for document: DocumentModel, with sign: [String: UIImage]) {
        var imageData = [String: Data]()
        for (key, value) in sign {
            imageData[key] = value.jpegData(compressionQuality: 0.5)
        }
        let spinner = displaySpinner(onView: view)
        LibraryAPI.sharedInstance().postFieldsForm(for: document.id, with: formFieldsForRequest, to: email, signatures: imageData, from: currentAddress, success: { successPostFields in
            self.removeSpinner(spinner: spinner)
            
            try! self.realm.write {
                document.isDraft = false
                document.isSubmitted = true
            }

            self.showSuccessAlertWithAction(message: "The document \"\(document.name)\" was sent to \(email). Check your email!", handler: { _ in
                self.navigationController?.popViewController(animated: true)
            })
            NotificationCenter.default.post(name: Notification.Name(rawValue: NotificationKeys.documentWasSentKey.rawValue), object: nil)
        }) { error in
            let message = error.count > 0 ?  error : "There was an unknown error submitting your data."
            self.removeSpinner(spinner: spinner)
            self.showErrorAlert(message: message)
        }
    }
    
    @IBAction func actionPreviewBtn(_ sender: Any) {
        if isAllFieldsFilled(isNeedEmail: false) {
            guard let document = selectDocument else { return }
            let signatures = getSignsForServer()
            preview(document: document, sign: signatures)
        }
    }
    
    func preview(document: DocumentModel, sign: [String: UIImage]) {
        var imageData = [String: Data]()
        for (key, value) in sign {
            imageData[key] = value.jpegData(compressionQuality: 0.5)
        }
        let spinner = self.displaySpinner(onView: self.view)
        LibraryAPI.sharedInstance().previewFormFields(for: document.id, with: self.formFieldsForRequest, signatures: imageData, from: currentAddress, success: { successPostFields in
            guard let docName = self.startDocumentTitle else { return }
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.downloadDocument(spinner: spinner, documentName: docName, documentsDirectoryURL: documentsDirectoryURL, fileUrl: successPostFields, success: { successDownload in
            })
        }) { error in
            self.removeSpinner(spinner: spinner)
            self.showErrorAlert(message: error)
        }
    }
    
    func downloadDocument(spinner: UIView, documentName: String, documentsDirectoryURL: URL, fileUrl: String, success: @escaping (_ successDownload: Bool) -> Void) {
        let filePath = documentsDirectoryURL.appendingPathComponent("preview_\(documentName).pdf")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: "\(realm.configuration.fileURL!.deletingLastPathComponent().path)/preview_\(documentName).pdf") {
            runDownload(spinner: spinner, fileUrl, filePath, success: { successDownload in
                success(successDownload)
            })
        } else {
            try! fileManager.removeItem(atPath: "\(realm.configuration.fileURL!.deletingLastPathComponent().path)/preview_\(documentName).pdf")
            runDownload(spinner: spinner, fileUrl, filePath, success: { successDownload in
                success(successDownload)
            })
        }
    }
    
    func runDownload(spinner: UIView, _ fileUrl: String, _ filePath: URL, success: @escaping (_ success: Bool) -> Void) {
        Downloader.load(url: URL(string: fileUrl)!, to: filePath, completion: {
            guard let titleFile = self.startDocumentTitle else { return }
            let title = titleFile
            let pdfPath = filePath
            self.showQLPreview(pdfPath, title, spinner)
        })
    }
    
    func removeEmptyView(baseRow: BaseRow) {
        for view in baseRow.baseCell.subviews {
            if let emptyView = view as? UIImageView {
                emptyView.removeFromSuperview()
            }
        }
    }
    
    func updateAnswerInDB(for line: FormModel, with text: String?) {
        try! realm.write {
            line.answer = text
        }
    }
    
    func updateSpecialEmailInDB(with value: String?, in document: DocumentModel) {
        try! realm.write {
            document.emailForSend = value
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

}
