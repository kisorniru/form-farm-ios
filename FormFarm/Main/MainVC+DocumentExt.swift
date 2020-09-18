//
//  MainVC+DocumentExt.swift
//  FormFarm
//
//  Created by a1 on 01.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit
import QuickLook
import RealmSwift

protocol DocumentProtocol {
    func initForRefreshTableData()
    func recieveAllDocuments()
    func recieveAllForms(for documents: [DocumentModel])
    func duplicateDocument(for document: DocumentModel, success: @escaping (_ document: DocumentModel) -> Void)
    func downloadFilesToDevice()
    func downloadOneDocument(document: DocumentModel, documentsDirectoryURL: URL, success: @escaping (_ successDownload: Bool) -> Void)
    func runDownload(_ document: DocumentModel, _ filePath: URL, success: @escaping (_ success: Bool) -> Void)
}

extension MainVC: DocumentProtocol {    
    typealias duplicatedDocument = (_ document: DocumentModel) -> Void
    
    func initForRefreshTableData() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
            if #available(iOS 13.0, *) {
                tableView.refreshControl?.backgroundColor = .systemBackground
            } else {
                tableView.refreshControl?.backgroundColor = .white
            }
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(MainVC.recieveAllDocuments), for: .valueChanged)
    }
    
    @objc func recieveAllDocuments() {
        refreshControl.beginRefreshing()
        if (!self.isLoadingNextPage) {
            self.documentsPage = 1
        }
        let submitter_id = UserDefaults.standard.integer(forKey: "id")
        LibraryAPI.sharedInstance().getAllDocuments(page: self.documentsPage, type: self.loadDocumentType, limit: 20, submitter_id: submitter_id, success: { allDocuments in
            self.documents = allDocuments
            if self.loadDocumentType == "draft" {
                self.allDocuments = allDocuments.filter({ $0.isDraft == false && $0.isWaiting == false  && $0.isSubmitted == false })
            }
            
            if self.loadDocumentType == "submitted" {
                self.waitingDocuments = allDocuments.filter({ $0.isWaiting == true || $0.isSubmitted == true })
            }

            if !self.refreshControl.isRefreshing {
                self.isLoadingNextPage = false
            }
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }) { error in
            self.showErrorAlert(message: error)
        }
    }
    
    func recieveAllForms(for documents: [DocumentModel]) {
        for document in documents {
            NetworkManager.isReachable { _ in
                if !document.isDraft {
                    LibraryAPI.sharedInstance().getFormsFromServer(for: document, success: { formsFromServer in
                        if formsFromServer.count > 0 {
                            print("SUCCESS DOWNLOAD FORMS FOR \(document.name)!")
                        }
                    }, failure: { error in
                        print("ERROR = \(error)")
                    })
                }
            }
        }
    }
    
    func duplicateDocument(for document: DocumentModel, success: @escaping duplicatedDocument) {
        NetworkManager.isReachable { _ in
            if !document.isDraft {
                LibraryAPI.sharedInstance().duplicateFormInServer(for: document, success: { duplicate in
                    self.documents.append(duplicate)
                    self.draftDocuments.append(duplicate)
                    self.tableView.reloadData()
                    success(duplicate)
                }) { error in
                    print(error)
                    print("There was an error duplicating the document")
                }
            }
        }
    }
    
    func removeDocument(for document: DocumentModel, currentRow: Int) {
        NetworkManager.isReachable { _ in
            if document.isDraft {
                LibraryAPI.sharedInstance().removeDocumentInServer(for: document, success: { removed in
                    let selectDoc = self.draftDocuments[currentRow]
                    self.draftDocuments.remove(at: currentRow)
                    try! self.realm.write {
                        selectDoc.isDraft = false
                        selectDoc.emailForSend = nil
                    }
                    
                    self.tableView.reloadData()
                }) { error in
                    print(error)
                    self.showErrorAlert(message: "The document \"\(document.name)\" cannot be removed")
                }
            }
        }
        
        NetworkManager.isUnreachable { _ in
            self.showErrorAlert(message: "The document \"\(document.name)\" cannot be removed")
        }
    }
    
    func downloadFilesToDevice() {
        let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        for document in documents {
            downloadOneDocument(document: document, documentsDirectoryURL: documentsDirectoryURL, success: { _ in })
        }
    }
    
    func downloadOneDocument(document: DocumentModel, documentsDirectoryURL: URL, success: @escaping (_ successDownload: Bool) -> Void) {
        let filePath = documentsDirectoryURL.appendingPathComponent("\(document.name).pdf")
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: "\(realm.configuration.fileURL!.deletingLastPathComponent().path)/\(document.name).pdf") {
            runDownload(document, filePath, success: { successDownload in
                success(successDownload)
            })
        } else {
            try! fileManager.removeItem(atPath: "\(realm.configuration.fileURL!.deletingLastPathComponent().path)/\(document.name).pdf")
            DispatchQueue.main.async {
                try! self.realm.write {
                    document.filePath = ""
                }
            }
            runDownload(document, filePath, success: { successDownload in
                success(successDownload)
            })
        }
    }
    
    func runDownload(_ document: DocumentModel, _ filePath: URL, success: @escaping (_ success: Bool) -> Void) {
        if document.preview_url.count == 0 {
            showErrorAlert(message: "The document preview is not valid.")
            success(false)
            return
        }
        Downloader.load(url: URL(string: document.preview_url)!, to: filePath, completion: {
            DispatchQueue.main.async {
                try! self.realm.write {
                    document.filePath = String(describing: filePath)
                    success(true)
                }
            }
        })
    }
}
