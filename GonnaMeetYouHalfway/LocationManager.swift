//
//  LocationManager.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D?

    private override init() {
        super.init()
        if (CLLocationManager.locationServicesEnabled()) {
            setupLocationManager()
        }
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    
}

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //  Check access for user location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
//            showSettingsAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
        }
    }
    
    private func showSettingsAlert() {
//        // Create the actions buttons for settings alert
//        let okAction = UIAlertAction(title: "OK", style: .default) {
//            UIAlertAction in
//            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
//        }
//        
//        showAlert(title: "Error",
//                  message: "No access to location services. Do you want to change your settings now?",
//                  buttonOneTitle: "Go to Settings",
//                  cancelButtonTitle: "Cancel",
//                  action: okAction)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
