//
//  PersistencyManager.swift
//  FormFarm
//
//  Created by a1 on 26.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift

enum ResultsError: Error {
    case notFoundElements
    case notExistModel
}

class RealmManager {
    let realm = try! Realm()
    
    //documents:
    func writeDocumentsToRealm(documents: [DocumentModel]) {
        for element in documents {
            let realm = try! Realm()
            try! realm.write {
                realm.add(element, update: .all)
            }
        }
    }
    
    func readDocumentsFromRealm() throws -> [DocumentModel] {
        guard let documents = try? Realm().objects(DocumentModel.self) else {
            throw ResultsError.notExistModel
        }
        guard documents.count > 0 else {
            throw ResultsError.notFoundElements
        }
        return Array(documents)
    }
    
    func deleteDocumentsFromRealm(documents: [DocumentModel]) {
        let realm = try! Realm()
        let ids = documents.map { $0.id }
        let documentsToDelete = realm.objects(DocumentModel.self).filter("id IN %@", ids)
        try! realm.write {
            realm.delete(documentsToDelete)
        }
    }
    
    //forms:
    func writeFormsToRealm(forms: [FormModel]) {
        for element in forms {
            let realm = try! Realm()
            try! realm.write {
                realm.add(element, update: .all)
            }
        }
    }
    
    func readFormsFromRealm(by document: DocumentModel) throws -> [FormModel] {
        guard let forms = try? Realm().objects(FormModel.self) else {
            throw ResultsError.notExistModel
        }
        let filterForms = forms.filter("document_id = %@", document.id)
        guard filterForms.count > 0 else {
            throw ResultsError.notFoundElements
        }
        let realmForms = filterForms.sorted(by: {$0.order < $1.order})
        return Array(realmForms)
    }
    
    func deleteFormsFromRealm(by document: DocumentModel) {
        let realm = try! Realm()
        let formsToDelete = realm.objects(FormModel.self).filter("document_id = %@", document.id)
        try! realm.write {
            realm.delete(formsToDelete)
        }
    }
    
    //forms for sent:
    func writeWaitFormsToRealm(_ waitForm: FormWaitModel) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(waitForm, update: .all)
        }
    }
    
    func readWaitFormsFromRealm() throws -> [FormWaitModel] {
        guard let waitForms = try? Realm().objects(FormWaitModel.self) else {
            throw ResultsError.notExistModel
        }
        guard waitForms.count > 0 else {
            throw ResultsError.notFoundElements
        }
        return Array(waitForms)
    }
}
