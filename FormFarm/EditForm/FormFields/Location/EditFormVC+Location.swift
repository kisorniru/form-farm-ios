//
//  EditFormVC+Location.swift
//  FormFarm
//
//  Created by a1 on 13.02.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import Eureka
import LocationPicker
import CoreLocation
import MapKit

protocol LocationProtocol {
    func createLocationBtn(for line: FormModel) -> Section
    func setLocationDescriptions(for locationPicker: LocationPickerViewController, line: FormModel)
    func setAddressToLocationRow(for line: FormModel, with title: String?)
}

extension EditFormVC: LocationProtocol {
    
    func createLocationBtn(for line: FormModel) -> Section {
        return Section(line.name) <<< ButtonRow(line.slug) { row in
            row.presentationMode = .segueName(segueName: IdentifierSegue.locationSegue.rawValue, onDismiss: nil)
            if let answer = line.answer {
                row.title = answer
                formFieldsForRequest[line.slug] = answer as AnyObject
            } else {
                row.title = "Tap to select location"
            }
        }
    }
    
    func setLocationDescriptions(for locationPicker: LocationPickerViewController, line: FormModel) {
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
    
    func setAddressToLocationRow(for line: FormModel, with title: String? = nil) {
        guard let row = form.rowBy(tag: line.slug) else { return }
        if let locationString = title {
            row.title = locationString
        } else {
            row.title = self.location.flatMap({ $0.title }) ?? "Add address"
        }
        if row.title != "Add address" {
            self.updateAnswerInDB(for: line, with: row.title)
            self.formFieldsForRequest[line.slug] = row.title as AnyObject
            for view in row.baseCell.subviews {
                if let emptyView = view as? UIImageView {
                    emptyView.removeFromSuperview()
                }
            }
        }
        row.updateCell()
    }
}
