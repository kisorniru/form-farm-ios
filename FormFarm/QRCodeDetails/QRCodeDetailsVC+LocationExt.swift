//
//  QRCodeDetailsVC+LocationExt.swift
//  FormFarm
//
//  Created by Maria on 20.09.2018.
//  Copyright © 2018 fruktorum. All rights reserved.
//

import Foundation
import CoreLocation

extension QRCodeDetailsVC: CLLocationManagerDelegate {
    
    func getCurrentLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = manager.location else { return }
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
            if let error = error {
                print("Reverse geocoder failed with error = \(error.localizedDescription)")
            }
            if let placemarks = placemarks, placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(placemark: pm)
            } else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark) {
        //stop updating location to save battery life
        locationManager.stopUpdatingLocation()
        let subThoroughfare = placemark.subThoroughfare ?? ""
        let thoroughfare = placemark.thoroughfare ?? ""
        let city = placemark.locality ?? ""
        let administrativeArea = placemark.administrativeArea ?? ""
        let postalCode = placemark.postalCode ?? ""
        currentAddress = "\(subThoroughfare) \(thoroughfare), \(city), \(administrativeArea) \(postalCode)"
        tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("ERROR GET CURRENT LOCATION = \(error.localizedDescription)")
        showErrorAlert(message: "Check your geolocation settings and try again")
    }
}

