//
//  LocationManager.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import MapKit


class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    var locationManager: CLLocationManager!
    var userLocation: Variable<CLLocationCoordinate2D?> = Variable(nil)
    var placemark: CLPlacemark?
    
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
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation.value = location.coordinate
        }
        
        CLGeocoder().reverseGeocodeLocation(locations.last!, completionHandler: {  (placemarks, error) in
            if let placemarks = placemarks {
                self.placemark = placemarks[0] // user’s current address
            }
        })

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
