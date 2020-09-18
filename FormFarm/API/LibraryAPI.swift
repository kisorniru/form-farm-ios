//
//  LibraryAPI.swift
//  FormFarm
//
//  Created by a1 on 23.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Alamofire

class LibraryAPI {
    
    static var instance: LibraryAPI!
    
    class func sharedInstance() -> LibraryAPI {
        self.instance = (self.instance ?? LibraryAPI())
        return self.instance
    }
    
    typealias successLogin = (_ responseLogin: [String: AnyObject]) -> Void
    typealias successLogout = (_ responseLogout: Bool) -> Void
    typealias successAuthUser = (_ responseUser: [String: AnyObject]) -> Void
    typealias recieveAllDocuments = (_ allDocuments: [DocumentModel]) -> Void
    typealias recieveForms = (_ forms: [FormModel]) -> Void
    typealias successPostForms = (_ success: String) -> Void
    typealias successPostQRcode = (_ document: DocumentModel) -> Void
    typealias successPostServiceLogs = (_ success: Bool) -> Void
    typealias duplicateDocument = (_ document: DocumentModel) -> Void
    typealias removeDocument = (_ document: DocumentModel) -> Void
    typealias failureHandler = (_ error: String) -> Void
    
    let realmManager = RealmManager()
    let serverManager = ServerManager()
    
    let headers: HTTPHeaders = [
        "Accept": "application/json",
        "content-type": "application/json"
    ]
    
    //LOGIN:
    func postLoginDataToServer(email: String, password: String, success: @escaping successLogin, failure: @escaping failureHandler) {
        let body: [String: String] = [
            "keep30days": "true",
            "email": email,
            "password": password
        ]
        RequestManager(url: LoginUrlType.login.setup(), httpMethod: .post).sendAlamofireRequest(parameters: body, headers: headers, outputType: [String: AnyObject].self, success: { response in
            if response["token_type"] != nil {
                success(response)
            }
        }) { error in
            let message = (error["message"] != nil ? error["message"] : error["error"]) as! String
            failure(message)
        }
    }
    
    //LOGOUT:
    func logoutDataFromServer(success: @escaping successLogout, failure: @escaping failureHandler) {
        RequestManager(url: LoginUrlType.logout.setup(), httpMethod: .post).sendAlamofireRequest(parameters: nil, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            let message = response["message"] as! String
            if message == "Successfully logged out" {
                success(true)
            } else {
                print("ERROR LOG OUT")
            }
        }) { error in
            failure("Error trying to logging out")
        }
    }
    
    // GET AUTH USER INFO:
    func getAuthUserInfo(success: @escaping successAuthUser, failure: @escaping failureHandler) {
        RequestManager(url: LoginUrlType.me.setup(), httpMethod: .get).sendAlamofireRequest(parameters: nil, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            success(response)
        }) { error in
            failure("Error getting the user info")
        }
    }

    //GET ALL DOCUMENTS:
    func getAllDocuments(page: Int, type: String, limit: Int, submitter_id: Int, success: @escaping recieveAllDocuments, failure: @escaping failureHandler) {
        NetworkManager.isReachable { _ in
            self.serverManager.getDocumentsFromServer(page, type: type, limit: limit, submitter_id: submitter_id, success: { documentsFromServer in
                do {
                    var documentsFromRealm = try self.realmManager.readDocumentsFromRealm()
                    var newDocs = [DocumentModel]()

                    if (page == 1) { // reloading
                        var realmDocs = [DocumentModel]()
                        if type == "draft" {
                            realmDocs = documentsFromRealm.filter({ $0.isDraft == false && $0.isWaiting == false && $0.isSubmitted == false })
                        }
                        
                        if type == "submitted" {
                            realmDocs = documentsFromRealm.filter({ $0.isSubmitted == true })
                        }

                        self.realmManager.deleteDocumentsFromRealm(documents: realmDocs)
                    }

                    documentsFromRealm = try self.realmManager.readDocumentsFromRealm()
                    for serverDoc in documentsFromServer {
                        var exists = false
                        for realmDoc in documentsFromRealm {
                            if (realmDoc.id == serverDoc.id) {
                                exists = true
                            }
                        }
                        
                        if !exists {
                            newDocs.append(serverDoc)
                        }
                    }

                    self.realmManager.writeDocumentsToRealm(documents: newDocs)
                    documentsFromRealm = try self.realmManager.readDocumentsFromRealm()
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM-dd-yyyy"
                    // let sortedDocs = documentsFromRealm.sorted(by: { dateFormatter.date(from: $0.updated_at)!.compare(dateFormatter.date(from: $1.updated_at)!) == .orderedDescending })
                    let sortedDocs = documentsFromRealm.sorted(by: { $0.id > $1.id })
                    success(sortedDocs)
                    return
                } catch {
                    // We don't have info in realm, let's add them and return them
                    self.realmManager.writeDocumentsToRealm(documents: documentsFromServer)
                    success(documentsFromServer)
                }
            }) { error in
                failure("failed getting documents from server")
            }
        }
        NetworkManager.isUnreachable { _ in
            do {
                let documentsFromDB = try self.realmManager.readDocumentsFromRealm()
                success(documentsFromDB)
            } catch {
                failure("Error with get documents from database")
            }
        }
    }
    
    //DUPLICATE FORM
    func duplicateFormInServer(for document: DocumentModel, success: @escaping duplicateDocument, failure: @escaping failureHandler) {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "MMM dd,yyyy"
        let formattedDate = format.string(from: date)
        
        format.dateFormat = "HH:mm:ss"
        let formattedTime = format.string(from: date)

        let parameters: [String: String] = [
            "name": "Submission of \(document.name) on \(formattedDate) at \(formattedTime)",
            "status": "typing"
        ]
        self.serverManager.duplicateDocumentInServer(for: document, with: parameters, success: { duplicate in
            var docs = [DocumentModel]()
            docs.append(duplicate)
            self.realmManager.writeDocumentsToRealm(documents: docs)
            success(duplicate)
        }) { error in
            print(error)
            failure(error)
        }
    }
    
    //GET FORMS FOR DOCUMENT:
    func getFormsFromServer(for document: DocumentModel, success: @escaping recieveForms, failure: @escaping failureHandler) {
        serverManager.getFormFromServer(for: document, success: { form in
            let sortedForm = form.sorted(by: {$0.order < $1.order})
            self.realmManager.deleteFormsFromRealm(by: document)
            self.realmManager.writeFormsToRealm(forms: sortedForm)
            success(sortedForm)
        }) { error in
            failure("Error getting the form from Server")
        }
    }
    
    func getFormsFromDB(for document: DocumentModel, success: @escaping recieveForms, failure: @escaping failureHandler) {
        do {
            let formsFromDB = try realmManager.readFormsFromRealm(by: document)
            success(formsFromDB)
        } catch {
            failure("Error with get forms from DB")
        }
    }
    
    //POST FIELDS TO SERVER:
    func postFieldsForm(for documentId: Int, with fields: [String: AnyObject], to email: String? = nil, signatures: [String: Data], from location: String, success: @escaping successPostForms, failure: @escaping failureHandler) {
        var parameters: [String: AnyObject] = fields
        if email != nil {
            parameters["receiver_email"] = email as AnyObject
            parameters["sender_location"] = location as AnyObject
        }
        serverManager.postFormToServer(for: documentId, with: parameters, imageData: signatures, success: { successPreviewUrl in
            success(successPreviewUrl)
        }) { error in
            print(error)
            failure("Error submitting the form")
        }
    }
    
    //PREVIEW FIELDS TO SERVER:
    func previewFormFields(for documentId: Int, with fields: [String: AnyObject], to email: String? = nil, signatures: [String: Data], from location: String, success: @escaping successPostForms, failure: @escaping failureHandler) {
        var parameters: [String: AnyObject] = fields
        if email != nil {
            parameters["receiver_email"] = email as AnyObject
            parameters["sender_location"] = location as AnyObject
        }

        serverManager.previewFormFields(for: documentId, with: parameters, imageData: signatures, success: { successPreviewUrl in
            success(successPreviewUrl)
        }) { error in
            print(error)
            failure("Error building the PDF")
        }
    }
    
    //POST QR CODE STRING TO SERVER:
    func postCodedQRString(codedString: String, success: @escaping successPostQRcode, failure: @escaping failureHandler) {
        let parameters: [String: AnyObject] = [
            "decoded_qrcode": [
                "hash": codedString
            ] as AnyObject
        ]
        serverManager.postCodedQRstringToServer(with: parameters, success: { document in
            var newDocs = [DocumentModel]()
            newDocs.append(document)
            self.realmManager.writeDocumentsToRealm(documents: newDocs)
            success(document)
        }) { error in
            failure(error)
        }
    }
    
    //POST SERVICE LOGS TO SERVER:
    func postServiceLogs(with info: [String: AnyObject], images: [String: Data], success: @escaping successPostServiceLogs, failure: @escaping failureHandler) {
        serverManager.postServiceLogsToServer(with: info, images: images, success: { successPost in
            if successPost {
                success(successPost)
            }
        }) { error in
            failure(error)
        }
    }
    
    //REMOVE DOCUMENT
    func removeDocumentInServer(for document: DocumentModel, success: @escaping removeDocument, failure: @escaping failureHandler) {
        self.serverManager.removeDocumentInServer(for: document, success: { successRemove in
            if successRemove {
                success(document)
                return
            }
            failure("Error removing document.")
        }) {error in
            print(error)
            failure(error)
        }
    }
    
}
