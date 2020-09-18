//
//  FormModel.swift
//  FormFarm
//
//  Created by a1 on 05.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift

class FormModel: Object {
    
    @objc dynamic var compound_id = ""
    @objc dynamic var id = 0
    @objc dynamic var slug = ""
    @objc dynamic var name = ""
    @objc dynamic var order = 0
    @objc dynamic var document_id = 0
    @objc dynamic var input_type = 0
    @objc dynamic var details = ""
    @objc dynamic var required = false
    @objc dynamic var disabled = false
    @objc dynamic var placeholder: String?
    
    //meta:
    var data_type = RealmOptional<Int>()
    var date_type = RealmOptional<Int>()
    var values = List<String>()
    
    @objc dynamic var answer: String?
    @objc dynamic var answerImage: Data? = nil
    
    override static func primaryKey() -> String? {
        return "compound_id"
    }
    
    func buildCompountId() -> String {
        return "document_\(document_id)_field_\(id)"
    }
}
