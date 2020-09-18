//
//  DocumentModel.swift
//  FormFarm
//
//  Created by a1 on 26.01.2018.
//Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import RealmSwift

class DocumentModel: Object {
    
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var preview_url = ""
    @objc dynamic var updated_at = "2018/02/02 11:11:11"
    @objc dynamic var filePath: String?
    
    @objc dynamic var isDraft = false
    @objc dynamic var isSubmitted = false
    @objc dynamic var isWaiting = false
    
    @objc dynamic var emailForSend: String?
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

