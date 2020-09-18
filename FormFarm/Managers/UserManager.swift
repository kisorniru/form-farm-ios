//
//  UserManager.swift
//  FormFarm
//
//  Created by a1 on 12.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation

struct UserManager {
    
    enum KeyValue: String {
        case id = "id"
        case company = "company"
        case email = "email"
        case firstName = "first_name"
        case secondName = "second_name"
    }
    
    static func save(value: Any, key: KeyValue) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    static func recieve(key: KeyValue) -> String {
        if let value = UserDefaults.standard.value(forKey: key.rawValue) as? String {
            return value
        }
        return ""
    }
}
