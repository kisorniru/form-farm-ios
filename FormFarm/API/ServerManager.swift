//
//  ServerManager.swift
//  FormFarm
//
//  Created by a1 on 26.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import ObjectMapper_Realm
import ObjectMapper

class ServerManager {
    typealias recieveDocuments = (_ documents: [DocumentModel]) -> Void
    typealias recieveSpecificForm = (_ specificForm: [FormModel]) -> Void
    typealias duplicateDocument = (_ document: DocumentModel) -> Void
    typealias successSendForm = (_ response: String) -> Void
    typealias successPostQRString = (_ document: DocumentModel) -> Void
    typealias successPostInfo = (_ success: Bool) -> Void
    typealias failureHandler = (_ error: String) -> Void
    typealias removeDocument = (_ success: Bool) -> Void
    
    //GET DOCUMENTS FROM SERVER
    func getDocumentsFromServer(_ page: Int, type: String, limit: Int, submitter_id: Int, success: @escaping recieveDocuments, failure: @escaping failureHandler) {
        var path = ""
        if (type == "draft") {
            path = "/documents?ignore=pending&limit=\(limit)&page=\(page)"
        } else {
            path = "/submissions?limit=\(limit)&page=\(page)&submitter=\(submitter_id)"
        }

        RequestManager(url: MainUrlType.allDocuments.setup(param: path), httpMethod: .get).sendAlamofireRequest(parameters: nil, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            var info = response
            info["documents"] = response["data"]
            if let baseData = Mapper<BaseModel>().map(JSON: info) {
                if baseData.status {
                    success(Array(baseData.documents))
                    return
                } else if !baseData.errors.isEmpty {
                    print("ERROR get Documents from Server = \(baseData.errors[0].value!)")
                    failure(baseData.errors[0].value!)
                    return
                }
            }
        }) { error in
            print(error)
            failure("Error getting documents from Server")
        }
    }

    //GET FORM FROM SERVER
    func getFormFromServer(for document: DocumentModel, success: @escaping recieveSpecificForm, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.getFormFields.setup(param: "\(document.id)"), httpMethod: .get).sendAlamofireRequest(parameters: nil, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            var info = response
            info["forms"] = response["data"]
            if let baseData = Mapper<BaseModel>().map(JSON: info) {
                if baseData.status {
                    for element in baseData.forms {
                        element.document_id = document.id
                        element.compound_id = element.buildCompountId()
                    }
                    success(Array(baseData.forms))
                    return
                } else if !baseData.errors.isEmpty {
                    print("ERROR get Forms from Server = \(baseData.errors[0].value!)")
                    failure(baseData.errors[0].value!)
                    return
                }
            }
        }) { error in
            failure("Failed getting fields")
        }
    }
    
    //DUPLICATE DOCUMENT
    func duplicateDocumentInServer(for document: DocumentModel, with parameters: [String: String], success: @escaping duplicateDocument, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.duplicateDocument.setup(param: "\(document.id)"), httpMethod: .post).sendAlamofireRequest(parameters: parameters, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            if let baseData = Mapper<BaseModel>().map(JSON: response) {
                if baseData.status {
                    let document = DocumentModel(value: response["data"])
                    success(document)
                    return
                } else if !baseData.errors.isEmpty {
                    failure(baseData.errors[0].value!)
                    return
                }
            }
            
            failure("Server error!")
            return
        }) { error in
            failure("There was an error generating the submission")
        }
    }
    
    //POST FIELDS FORM TO SERVER
    func postFormToServer(for documentId: Int, with parameters: [String: AnyObject], imageData: [String: Data]?, success: @escaping successSendForm, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.postFormFields.setup(param: "\(documentId)"), httpMethod: .post).sendAlamofireRequestWith(imageData: imageData, parameters: parameters, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            if let baseData = Mapper<BaseModel>().map(JSON: response) {
                if baseData.status {
                    if let previewUrl = response["preview_url"] as? String {
                        success(previewUrl)
                        return
                    }
                    failure(response["message"] as? String ?? "There was a server error")
                    return
                } else if !baseData.errors.isEmpty {
                    failure(baseData.errors[0].value!)
                    return
                } else {
                    failure("Server error!")
                }
            } else {
                failure("There was an error reading the server response")
            }
        }) { error in
            failure("Error requesting the data")
        }
    }
    
    //POST FIELDS FORM TO GENERATE PREVIEW
    func previewFormFields(for documentId: Int, with parameters: [String: AnyObject], imageData: [String: Data]?, success: @escaping successSendForm, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.previewForm.setup(param: "\(documentId)"), httpMethod: .post).sendAlamofireRequestWith(imageData: imageData, parameters: parameters, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            if let baseData = Mapper<BaseModel>().map(JSON: response) {
                if baseData.status {
                    if let previewUrl = response["preview_url"] as? String {
                        success(previewUrl)
                        return
                    }
                    failure("Error here")
                    return
                } else if !baseData.errors.isEmpty {
                    print("ERROR post Forms to Server = \(baseData.errors[0].value!)")
                    failure(baseData.errors[0].value!)
                    return
                } else {
                    failure("Server error!")
                }
            }
        }) { error in
            failure("Error Generating the pdf")
        }
    }
    
    //POST CODED STRING TO SERVER
    func postCodedQRstringToServer(with parameters: [String: AnyObject], success: @escaping successPostQRString, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.postDecodedQRcode.setup(), httpMethod: .post).sendAlamofireRequest(parameters: parameters, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            var info = response
            info["documents"] = response["data"]
            if let baseData = Mapper<BaseModel>().map(JSON: info) {
                if baseData.status {
                    success(baseData.documents[0])
                    return
                } else if !baseData.errors.isEmpty {
                    print("ERROR get Documents from Server = \(baseData.errors[0].value!)")
                    failure(baseData.errors[0].value!)
                    return
                }
            }
        }) { error in
            let message = error["message"] as! String
            failure(message)
        }
    }
    
    //POST SERVICE LOGS TO SERVER
    func postServiceLogsToServer(with parameters: [String: AnyObject], images: [String: Data], success: @escaping successPostInfo, failure: @escaping failureHandler) {
        
        RequestManager(url: MainUrlType.postServiceLogs.setup(), httpMethod: .post).sendAlamofireRequestSecviceLog(imageData: images, parameters: parameters, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            if let baseData = Mapper<BaseModel>().map(JSON: response) {
                if baseData.status {
                    success(baseData.status)
                } else if !baseData.errors.isEmpty {
                    print("ERROR post ServiceLogs to Server = \(baseData.errors[0].value!)")
                    failure(baseData.errors[0].value!)
                }
            }
        }, failure: { error in
            failure(error)
        })
    }

    // DELETE DOCUMENT IN SERVER
    func removeDocumentInServer(for document: DocumentModel, success: @escaping removeDocument, failure: @escaping failureHandler) {
        RequestManager(url: MainUrlType.removeDocument.setup(param: "\(document.id)"), httpMethod: .delete).sendAlamofireRequest(parameters: nil, headers: HeaderManager.setHeader(), outputType: [String: AnyObject].self, success: { response in
            success(true)
        }) { error in
            failure("Failed removing document")
        }
    }
}
