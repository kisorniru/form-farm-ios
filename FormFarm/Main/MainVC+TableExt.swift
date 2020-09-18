//
//  MainViewController+TableExt.swift
//  FormFarm
//
//  Created by a1 on 23.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

extension MainVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch stateMainTable {
        case .allDocs:
            return allDocuments.count
        case .draftDocs:
            return draftDocuments.count
        case .waitingDocs:
            return waitingDocuments.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch stateMainTable {
        case .allDocs:
            return createCell(for: allDocuments, at: indexPath, trashIsHidden: true)
        case .draftDocs:
            return createCell(for: draftDocuments, at: indexPath, trashIsHidden: false)
        case .waitingDocs:
            return createCell(for: waitingDocuments, at: indexPath, trashIsHidden: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch stateMainTable {
        case .allDocs:
            selectCell(by: allDocuments, at: indexPath)
        case .draftDocs:
            selectCell(by: draftDocuments, at: indexPath)
        case .waitingDocs:
            selectCell(by: waitingDocuments, at: indexPath)
        }
    }
    
    func createCell(for documents: [DocumentModel], at indexPath: IndexPath, trashIsHidden: Bool) -> MainCell {
        let document = documents[indexPath.row]
        let model = MainCellModel(document: document)
        let cell = tableView.reusableCell(cellModel: model, for: indexPath)
        cell.sendButton.isHidden = true
        cell.trashButton.isHidden = trashIsHidden

        if (document.isSubmitted != false) {
            cell.trashButton.isHidden = true
        }
        
        if document.isWaiting != false {
            cell.sendButton.isHidden = false
        }

        return cell
    }
    
    func selectCell(by documents: [DocumentModel], at indexPath: IndexPath) {
        var selectDocument: DocumentModel
        switch stateMainTable {
        case .allDocs:
            selectDocument = self.allDocuments[indexPath.row]
        case .draftDocs:
            selectDocument = self.draftDocuments[indexPath.row]
        case .waitingDocs:
            selectDocument = self.waitingDocuments[indexPath.row]
        }
        let selectedCell = tableView.cellForRow(at: indexPath) as? MainCell

        if !selectDocument.isDraft && !selectDocument.isSubmitted && !selectDocument.isWaiting {
            let spinner = self.displaySpinner(onView: self.view)

            self.duplicateDocument(for: selectDocument, success: { duplicate in
                selectedCell?.currentDocument = duplicate
                self.tableView.deselectRow(at: indexPath, animated: true)
                self.removeSpinner(spinner: spinner)

                self.performSegue(withIdentifier: IdentifierSegue.showEditForm.rawValue, sender: selectedCell)
            })
        } else if selectDocument.isDraft || selectDocument.isWaiting {
            selectedCell?.currentDocument = selectDocument
            tableView.deselectRow(at: indexPath, animated: true)
            performSegue(withIdentifier: IdentifierSegue.showEditForm.rawValue, sender: selectedCell)
        } else {
            self.previewDocument(currentRow: indexPath.row)
        }
    }
}
