//
//  TypeManager.swift
//  FormFarm
//
//  Created by a1 on 13.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

enum FormTypeNumber: Int {
    case textField //0
    case textArea  //1
    case select    //2
    case radio     //3
    case date      //4
    case signature //5
    case location  //6
    case info      //7
    case calculation //8
    case ticket_id //9
}

enum TextFieldTypeNumber: Int {
    case text
    case name
    case int
    case decimal
    case phone
    case email
}

enum DateTypeNumber: Int {
    case slashStyle     // 'MM/dd/yyyy' - 02/09/2018
    case monthStyle     // 'MMMM yyyy' - February 2018
    case commaStyle     // 'MMM d, yyyy' - Feb 9, 2018
    case dotStyle       // 'dd.MM.yy' - 09.02.18
}

public struct CalculationItem: Codable {
    var description: String? = ""
    var quantity: Double?
    var price: Double?
    var total: Double?
}

public struct CalculationData: Codable {
    var subtotal: Double? = 0.00
    var total: Double? = 0.00
    var items: Array<CalculationItem> = []
}
