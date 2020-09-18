//
//  RequestManager.swift
//  FormFarm
//
//  Created by a1 on 29.01.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import SystemConfiguration
import Alamofire

class RequestManager: NSObject {
    var url: String
    var httpMethod: HTTPMethod
    
    init(url: String, httpMethod: HTTPMethod) {
        self.url = url
        self.httpMethod = httpMethod
    }
    
    func sendAlamofireRequest<T>(parameters: Parameters?, headers: HTTPHeaders?, outputType: T.Type?, success: @escaping (_ jsonResult: T) -> Void, failure: @escaping (_ error: T) -> Void) {
        Alamofire.request(url, method: httpMethod, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            let code: Int = (response.response?.statusCode)!
            if code == 401 {
                HeaderManager.clear()
                NavigationManager.goToLoginView()
            }

            if let jsonResult = response.result.value as? T {
                if code >= 200 && code <= 299 {
                    success(jsonResult)
                } else if code >= 400 && code <= 500 {
                    failure(jsonResult)
                }
            } else {
                print("ERROR ALAMOFIRE RESPONSE with url = \(self.url)")
            }
        }
    }
    
    func sendAlamofireRequestWith<T>(imageData: [String: Data]?, parameters: [String: AnyObject]?, headers: HTTPHeaders?, outputType: T.Type?, success: @escaping (_ jsonResult: T) -> Void, failure: @escaping (_ error: String) -> Void) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters! {
                key != "receiver_email" && key != "sender_location"
                    ? multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "variables[\(key)]" as String)
                    : multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "\(key)" as String)
            }
            if let data = imageData {
                for (key, value) in data {
                    multipartFormData.append(value, withName: "variables[\(key)]", fileName: "\(key).png", mimeType: "image/png")
                }
            }
        }, usingThreshold: UInt64.init(), to: url, method: httpMethod, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let error = response.error {
                        failure(error.localizedDescription)
                        return
                    }
                    if let jsonResult = response.result.value as? T {
                        success(jsonResult)
                        return
                    } else {
                        print("ERROR ALAMOFIRE FORM RESPONSE with url = \(self.url)")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                failure(error.localizedDescription)
            }
        }
    }
    
    func sendAlamofireRequestSecviceLog<T>(imageData: [String: Data]?, parameters: [String: AnyObject]?, headers: HTTPHeaders?, outputType: T.Type?, success: @escaping (_ jsonResult: T) -> Void, failure: @escaping (_ error: String) -> Void) {
        Alamofire.upload(multipartFormData: { multipartFormData in
            for (key, value) in parameters!["service_log"] as! [String: AnyObject] {
                if key != "info" {
                    multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: "service_log[\(key)]" as String)
                } else {
                    if let infoData = value as? [String: AnyObject] {
                        for (infoKey, infoValue) in infoData {
                            multipartFormData.append("\(infoValue)".data(using: String.Encoding.utf8)!, withName: "service_log[\(key)][\(infoKey)]" as String)
                        }
                    }
                }
            }
            if let data = imageData {
                for (key, value) in data {
                    multipartFormData.append(value, withName: "service_log[info][\(key)]", fileName: "\(key).png", mimeType: "image/png")
                }
            }
        }, usingThreshold: UInt64.init(), to: url, method: httpMethod, headers: headers) { result in
            switch result {
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    if let error = response.error {
                        failure(error.localizedDescription)
                        return
                    }
                    if let jsonResult = response.result.value as? T {
                        success(jsonResult)
                        return
                    } else {
                        print("ERROR ALAMOFIRE FORM RESPONSE with url = \(self.url)")
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
                failure(error.localizedDescription)
            }
        }
    }
}
