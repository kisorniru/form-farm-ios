//
//  HeaderManager.swift
//  FormFarm
//
//  Created by a1 on 29.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Alamofire

struct HeaderManager {
    
    enum KeyValue: String {
        case accessToken = "accessToken"
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
    
    static func clear() {
        UserDefaults.standard.set("", forKey: KeyValue.accessToken.rawValue)
    }
    
    static func setHeader() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            "authorization": "Bearer " + HeaderManager.recieve(key: .accessToken),
        ]
        return headers
    }
}


