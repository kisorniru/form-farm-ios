//
//  Downloader.swift
//  FormFarm
//
//  Created by a1 on 01.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation

class Downloader {
    
    class func load(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    //print("Success: \(statusCode)")
                }
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("Error writing file \(localUrl) : \(writeError)")
                    completion()
                }
            } else {
                print("Failure: %@", error?.localizedDescription ?? "ERROR")
                completion()
            }
        }
        task.resume()
    }
}
