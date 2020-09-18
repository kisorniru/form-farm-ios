//
//  InfoModel.swift
//  FormFarm
//
//  Created by Maria on 19.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper_Realm
import ObjectMapper

class InfoModel: Object, Mappable {
    
    @objc dynamic var id = 0
    @objc dynamic var details = ""
    @objc dynamic var required = false
    @objc dynamic var variable = ""
    @objc dynamic var order = 0
    @objc dynamic var input_type = 0

    //meta:
    @objc dynamic var placeholder: String?
    var data_type = RealmOptional<Int>()
    var date_type = RealmOptional<Int>()
    var values = List<String>()

    @objc dynamic var answer: String?
    @objc dynamic var answerImage: Data? = nil

    override static func primaryKey() -> String? {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        
        id         <- map["id"]
        details    <- map["details"]
        required   <- map["required"]
        variable   <- map["variable"]
        order      <- map["order"]
        input_type <- map["input_type"]
        
        if let metaData = map.JSON["meta"] as? [String: AnyObject] {
            placeholder = metaData["placeholder"] as? String
            data_type.value = metaData["data_type"] as? Int
            date_type.value = metaData["date"] as? Int
            if let values = metaData["values"] as? [AnyObject] {
                let items = List<String>()
                for value in values {
                    guard let item = value as? String else { return }
                    items.append(item)
                }
                self.values = items
            }
        }
    }
}
