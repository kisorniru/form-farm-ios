//
//  UrlManager.swift
//  FormFarm
//
//  Created by a1 on 29.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation

// Laravel API
// let SERVER_URL = "http://form-farm.test"
let SERVER_URL = "https://formfarmapi.amp.build"

enum LoginUrlType {
    
    case login
    case logout
    case me
    
    func setup() -> String {
        switch self {
        case .login: return "\(SERVER_URL)/api/auth/login"
        case .logout: return "\(SERVER_URL)/api/auth/logout"
        case .me: return "\(SERVER_URL)/api/auth/me"
        }
    }
}

enum MainUrlType {
    
    case allDocuments
    case getFormFields
    case duplicateDocument
    case postFormFields
    case previewForm
    case postDecodedQRcode
    case postServiceLogs
    case removeDocument
    
    func setup(param: String = "") -> String {
        switch self {
        case .allDocuments: return "\(SERVER_URL)/api\(param.count > 0 ?  param : "/documents?status=draft&limit=100&page=1")"
        case .getFormFields: return "\(SERVER_URL)/api/documents/\(param)/fields"
        case .duplicateDocument: return "\(SERVER_URL)/api/documents/\(param)/duplicate"
        case .postFormFields: return "\(SERVER_URL)/api/documents/\(param)/deliver"
        case .previewForm: return "\(SERVER_URL)/api/documents/\(param)/preview"
        case .postDecodedQRcode: return "\(SERVER_URL)/api/services/decoded_qrcodes"
        case .postServiceLogs: return "\(SERVER_URL)/api/service/logs"
        case .removeDocument: return "\(SERVER_URL)/api/documents/\(param)"
        }
    }
}

