//
//  EditFormVC+TicketID.swift
//  FormFarm
//
//  Created by Studio Guatemala on 3/18/20.
//  Copyright © 2020 fruktorum. All rights reserved.
//

import UIKit
import Foundation
import Eureka

protocol TicketIDProtocol {
    func createTicketIDRow(for line: FormModel) -> Section
}

extension EditFormVC: TicketIDProtocol {
    func createTicketIDRow(for line: FormModel) -> Section {
        return Section() <<< TextRow() { row in
            row.disabled = true
            row.title = line.name
            row.value = line.answer
        }
    }
}
