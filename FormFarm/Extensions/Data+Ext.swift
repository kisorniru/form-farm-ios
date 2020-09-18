//
//  Data+Ext.swift
//  FormFarm
//
//  Created by a1 on 02.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    func toString(dateFormat format: String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}


