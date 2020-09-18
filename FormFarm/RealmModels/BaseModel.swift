//
//  BaseModel.swift
//  FormFarm
//
//  Created by a1 on 06.02.2018.
//Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper_Realm
import ObjectMapper

class BaseModel: Object, Mappable {
    
    @objc dynamic var status = false
    var errors = List<StringObject>()
    var documents = List<DocumentModel>()
    var forms = List<FormModel>()
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        mapStatus(through: map)
        mapErrors(through: map)
        mapDocuments(through: map)
        mapForms(through: map)
    }
    
    func mapStatus(through map: Map) {
        var status: String?
        status <- map["data"]
        self.status = status?.count == 0 ? false : true
    }
    
    func mapErrors(through map: Map) {
        var errors: [String]? = nil
        let error = StringObject()
        error.value = map["message"] as? String
        self.errors.append(error)
        errors <- map["errors"]
        errors?.forEach { option in
            let value = StringObject()
            value.value = option
            self.errors.append(value)
        }
    }
    
    func mapDocuments(through map: Map) {
        var documents: [AnyObject]?
        documents <- map["documents"]
        documents?.forEach { option in
            let documentData = DocumentModel(value: option)
            self.documents.append(documentData)
        }
    }

    func mapForms(through map: Map) {
        var forms: [AnyObject]?
        forms <- map["forms"]
        forms?.forEach {option in
            let formData = FormModel(value: option)
            let optionType = option["type"] as? String
            formData.compound_id = formData.buildCompountId()
            formData.input_type = buildFieldType(option["type"] as? String ?? "")
            formData.data_type.value = buildFieldDataType(option["type"] as? String ?? "")
            formData.order = option["order"] as! Int
            if (optionType == "signature") {
                let signatureBase64 = option["signature"] as? String
                let imageData = Data(base64Encoded: signatureBase64 ?? "", options: [])
                formData.answerImage = imageData
            } else {
                formData.answer = option["value"] as? String ?? ""
            }
            formData.details = option["details"] as? String ?? ""
            formData.placeholder = option["placeholder"] as? String ?? ""
            formData.date_type.value = 0 // slashStyle - 'MM/dd/yyyy' - 02/09/2018

            if let metaData = option["metadata"] as? [String: AnyObject] {
                if let values = metaData["options"] as? [AnyObject] {
                    let items = List<String>()
                    for value in values {
                        let item = value as AnyObject
                        let label = item["label"] as! String
                        items.append(label)
                    }
                    formData.values = items
                }
            }
            self.forms.append(formData)
        }
    }

    func buildFieldType(_ type: String) -> Int {
        switch type {
        case "text_field":
            return 0;
        case "text_email":
            return 0;
        case "text_tel":
            return 0;
        case "text_number":
            return 0;
        case "text_password":
            return 0;
        case "text_area":
            return 1;
        case "multiple_select":
            return 2;
        case "dropdown":
            return 3;
        case "radio":
            return 3;        
        case "date":
            return 4;
        case "signature":
            return 5;
        case "location":
            return 6;
        case "information":
            return 7;
        case "info":
        return 7;
        case "calculation":
            return 8;
        case "ticket_id":
            return 9;
        default:
            return 0;
        }
    }

    func buildFieldDataType(_ type: String) -> Int {
        switch type {
        case "text_field":
            return 0;
        case "text_number":
            return 2;
        case "text_tel":
            return 4;
        case "text_email":
            return 5;
        case "date":
            return 0;
        default:
            return 0;
        }
    }
}

class StringObject: Object {
    @objc dynamic var value: String?
}
