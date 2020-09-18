//
//  QRCodeDetailsVC+LocationPicker.swift
//  FormFarm
//
//  Created by Maria on 21.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka
import LocationPicker
import CoreLocation
import MapKit

protocol QRLocationProtocol {
    func createLocationBtn(for line: InfoModel) -> Section
    func setLocationDescriptions(for locationPicker: LocationPickerViewController, line: InfoModel)
    func setAddressToLocationRow(for line: InfoModel, with title: String?)
}

extension QRCodeDetailsVC: QRLocationProtocol {
    
    func createLocationBtn(for line: InfoModel) -> Section {
        return Section(line.details) <<< ButtonRow(line.variable) { row in
            row.presentationMode = .segueName(segueName: IdentifierSegue.locationSegue.rawValue, onDismiss: nil)
            if let answer = line.answer {
                row.title = answer
                formFieldsForRequest[line.variable] = answer as AnyObject
            } else {
                row.title = "Tap to select location"
            }
        }
    }
    
    func setLocationDescriptions(for locationPicker: LocationPickerViewController, line: InfoModel) {
        locationPicker.location = self.location
        locationPicker.showCurrentLocationButton = true
        locationPicker.useCurrentLocationAsHint = true
        locationPicker.showCurrentLocationInitially = true
        locationPicker.mapType = .standard
        locationPicker.completion = { location in
            self.location = location
            self.setAddressToLocationRow(for: line)
        }
        // locationPicker.completionString = { locationString in
            // self.setAddressToLocationRow(for: line, with: locationString)
        // }
    }
    
    func setAddressToLocationRow(for line: InfoModel, with title: String? = nil) {
        guard let row = form.rowBy(tag: line.variable) else { return }
        if let locationString = title {
            row.title = locationString
        } else {
            row.title = self.location.flatMap({ $0.title }) ?? "Add address"
        }
        if row.title != "Add address" {
            self.updateAnswerInDB(for: line, with: row.title)
            self.formFieldsForRequest[line.variable] = row.title as AnyObject
            for view in row.baseCell.subviews {
                if let emptyView = view as? UIImageView {
                    emptyView.removeFromSuperview()
                }
            }
        }
        row.updateCell()
    }
}
