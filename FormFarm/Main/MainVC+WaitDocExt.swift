//
//  MainVC+WaitDocExt.swift
//  FormFarm
//
//  Created by Maria on 29.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation

protocol WaitDocProtocol {
    func resentWaitForms()
    func sentWaitDoc(with waitForms: FormWaitModel)
    func updateWaitList()
}

extension MainVC: WaitDocProtocol {
    
    func resentWaitForms() {
        do {
            waitForms = try realmManager.readWaitFormsFromRealm()
            for form in waitForms {
                sentWaitDoc(with: form)
            }
        } catch {
            print("NO WAIT FORMS")
        }
    }
    
    func sentWaitDoc(with waitForms: FormWaitModel) {
        let requestFields = Array(waitForms.requestFields)
        var dictFields = [String: AnyObject]()
        for field in requestFields {
            guard let key = field.key else { return }
            dictFields[key] = field.value as AnyObject
        }
        let signs = Array(waitForms.signs)
        var dictSigns = [String: Data]()
        for sign in signs {
            guard let key = sign.key else { return }
            dictSigns[key] = sign.value
        }
        LibraryAPI.sharedInstance().postFieldsForm(for: waitForms.documentId, with: dictFields, to: waitForms.email, signatures: dictSigns, from: currentAddress, success: { successPostFields in
            self.waitDocCounter += 1
        }) { error in
            self.showErrorAlert(message: error)
        }
    }
    
    func updateWaitList() {
        self.showSuccessAlert(message: "Documents from queue were sent. Check your email!")
        for doc in documents {
            try! realm.write {
                doc.isWaiting = false
                doc.isSubmitted = true
                doc.emailForSend = nil
                realm.delete(realm.objects(FormWaitModel.self))
            }
        }
        if stateMainTable == .waitingDocs {
            waitingDocuments = documents.filter({ $0.isWaiting != false || $0.isSubmitted != false })
            tableView.reloadData()
        }
    }
}
