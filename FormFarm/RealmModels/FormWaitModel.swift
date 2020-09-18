//
//  FormWaitModel.swift
//  FormFarm
//
//  Created by Maria on 27.06.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift

class FormWaitModel: Object {
    
    @objc dynamic var documentId = 0
    @objc dynamic var email = ""
    var requestFields = List<RequestField>()
    var signs = List<Sign>()
    
    override static func primaryKey() -> String? {
        return "documentId"
    }
}

class RequestField: Object {
    @objc dynamic var key: String? = nil
    @objc dynamic var value: String? = nil
}

class Sign: Object {
    @objc dynamic var key: String? = nil
    @objc dynamic var value: Data? = nil
}
