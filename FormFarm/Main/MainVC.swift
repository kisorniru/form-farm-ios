//
//  MainVC.swift
//  FormFarm
//
//  Created by a1 on 22.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import QuickLook
import RealmSwift
import CoreLocation

enum StateMainTable {
    case allDocs
    case draftDocs
    case waitingDocs
}

class MainVC: UIViewController, UIPopoverPresentationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nameBarButton: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    @IBOutlet weak var allDocBtn: UIButton!
    @IBOutlet weak var draftDocBtn: UIButton!
    @IBOutlet weak var waitingDocBtn: UIButton!
    @IBOutlet weak var docsStateBtn: UIButton!
    @IBOutlet weak var qrCodeStateBtn: UIButton!
    
    let realm = try! Realm()
    var editFormVC: EditFormVC?
    var loadDocumentType = "draft"
    var documentsPage: Int = 1
    var isLoadingNextPage = false
    var documents = [DocumentModel]()
    var allDocuments = [DocumentModel]()
    var draftDocuments = [DocumentModel]()
    var waitingDocuments = [DocumentModel]()
    let refreshControl = UIRefreshControl()
    var startItems = [PreviewItemModel(nil, nil)]
    var stateMainTable: StateMainTable = .allDocs
    var waitForms = [FormWaitModel]()
    var underline = UIView()
    var currentAddress = ""
    
    let networkManager = NetworkManager.sharedInstance
    let realmManager = RealmManager()
    let locationManager = CLLocationManager()
    
    var oldViewHight: CGFloat?
    
    var waitDocCounter = 0 {
        didSet {
            if waitDocCounter == waitForms.count {
                waitDocCounter = 0
                updateWaitList()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentLocation()
        createUnderline(with: view.frame.size)
        initNetworkManager()
        initNotificationObservers()
        tableView.tableFooterView = UIView()
        self.refreshControl.addTarget(self, action: #selector(MainVC.refresh), for: UIControl.Event.valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1019607843, green: 0.4705882353, blue: 0.1254901961, alpha: 1)
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.4705882353, blue: 0.1254901961, alpha: 1)
        allDocuments = documents.filter({ $0.isDraft == false && $0.isWaiting == false  && $0.isSubmitted == false })
        draftDocuments = documents.filter({ $0.isDraft != false })
        waitingDocuments = documents.filter({ $0.isWaiting != false  || $0.isSubmitted != false })
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let oldHight = oldViewHight {
            if oldHight > view.frame.size.height {
                var frame = view.frame
                frame.origin.y -= (oldHight-view.frame.size.height)
                frame.size.height += (oldHight-view.frame.size.height)
                view.frame = frame
                view.reloadInputViews()
            }
        } else {
            oldViewHight = view.frame.height
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        underline.removeFromSuperview()
        createUnderline(with: size)
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tapCell = sender as? MainCell {
            editFormVC = segue.destination as? EditFormVC
            editFormVC?.startDocumentTitle = tapCell.currentDocument!.name
            editFormVC?.selectDocument = tapCell.currentDocument
        }
    }
    
    func initNetworkManager() {
        networkManager.checkNetworkConnect(network: networkManager) { isConnect in
            if isConnect {
                self.resentWaitForms()
                self.recieveAllDocuments()
                self.initForRefreshTableData()
            } else {
                self.showErrorInternetConnectionAlert()
                self.recieveAllDocuments()
                self.initForRefreshTableData()
            }
        }
    }
    
    @IBAction func viewActionBtn(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }
        let currentRow = indexPath.row

        switch stateMainTable {
        case .waitingDocs:
            self.previewDocument(currentRow: currentRow)
        case .allDocs:
            let spinner = self.displaySpinner(onView: self.view)
            self.duplicateDocument(for: documents[currentRow], success: { duplicate in
                let mainCell = MainCell()
                mainCell.numberCell = currentRow
                mainCell.currentDocument = duplicate
                self.removeSpinner(spinner: spinner)

                self.performSegue(withIdentifier: IdentifierSegue.showEditForm.rawValue, sender: mainCell)
            })
        default:
            let mainCell = MainCell()
            mainCell.numberCell = currentRow
            mainCell.currentDocument = documents[currentRow]
            
            performSegue(withIdentifier: IdentifierSegue.showEditForm.rawValue, sender: mainCell)
        }
    }
    
    @IBAction func trashActionBtn(_ sender: UIButton) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: buttonPosition) else { return }
        let currentRow = indexPath.row
        
        switch stateMainTable {
        case .draftDocs:
            let selectDoc = draftDocuments[currentRow]
            self.removeDocument(for: selectDoc, currentRow: currentRow)
        case .waitingDocs:
            let selectDoc = waitingDocuments[currentRow]
            waitingDocuments.remove(at: currentRow)
            try! self.realm.write {
                selectDoc.isWaiting = false
                selectDoc.emailForSend = nil
            }
        default:
            return
        }
        tableView.reloadData()
    }
    
    @IBAction func allAction(_ sender: Any) {
        moveView(stopMoveButton: sender as! UIButton)
        self.documentsPage = 1
        self.loadDocumentType = "draft"
        self.recieveAllDocuments()
        stateMainTable = .allDocs
        changeColorTitleBtn(stateMainTable: stateMainTable)
        allDocuments = documents.filter({ $0.isDraft == false && $0.isWaiting == false  && $0.isSubmitted == false })
        tableView.reloadData()
    }
    
    @IBAction func draftAction(_ sender: Any) {
        moveView(stopMoveButton: sender as! UIButton)
        self.documentsPage = 1
        stateMainTable = .draftDocs
        changeColorTitleBtn(stateMainTable: stateMainTable)
        draftDocuments = documents.filter({ $0.isDraft != false })
        tableView.reloadData()
    }
    
    @IBAction func waitingAction(_ sender: Any) {
        moveView(stopMoveButton: sender as! UIButton)
        self.documentsPage = 1
        self.loadDocumentType = "submitted"
        self.recieveAllDocuments()
        stateMainTable = .waitingDocs
        changeColorTitleBtn(stateMainTable: stateMainTable)
        waitingDocuments = documents.filter({ $0.isWaiting != false || $0.isSubmitted != false })
        tableView.reloadData()
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    @objc func refresh(sender:AnyObject) {
        self.documentsPage = 1
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height

        if offsetY > (contentHeight - scrollView.frame.height) {
            if !self.isLoadingNextPage && !self.refreshControl.isRefreshing {
                self.documentsPage += 1
                self.isLoadingNextPage = true
                self.recieveAllDocuments()
            }
        }
    }

    func initNotificationObservers() {
        let documentWasSentKey = Notification.Name(rawValue: NotificationKeys.documentWasSentKey.rawValue)
        NotificationCenter.default.addObserver(forName: documentWasSentKey, object: nil, queue: nil, using: reloadDocumentsTable)
    }
    
    func previewDocument(currentRow: Int) {
        let spinner = self.displaySpinner(onView: self.view)
        let title = documents[currentRow].name
        if let filePath = documents[currentRow].filePath, let pdfPath = URL(string: filePath) {
            self.showQLPreview(pdfPath, title, spinner)
        } else {
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            downloadOneDocument(document: documents[currentRow], documentsDirectoryURL: documentsDirectoryURL, success: { successDownload in
                if successDownload {
                    let pdfPath = URL(string: self.documents[currentRow].filePath!)
                    self.showQLPreview(pdfPath!, title, spinner)
                } else {
                    self.removeSpinner(spinner: spinner)
                }
            })
        }
    }

    // observer when a document is submitted, let's reload the table
    func reloadDocumentsTable(notification: Notification) -> Void {
        self.documentsPage = 1
        self.isLoadingNextPage = false
        self.recieveAllDocuments()
    }
}
