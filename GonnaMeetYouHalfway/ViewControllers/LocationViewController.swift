//
//  LocationViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import RxSwift

class LocationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var map: MKMapView!
    
    private var locationFirstLoad = true
    var locationManager: CLLocationManager!
    var userLocation: CLLocationCoordinate2D?
    let mapLatDelta: CLLocationDegrees = 0.05
    let mapLonDelta: CLLocationDegrees = 0.05
    private (set) var authorized: Bool!
    
    //MARK: for test purpose
    var friendLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.436180, -122.395842)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.showsScale = true
        map.showsUserLocation = true
        if (CLLocationManager.locationServicesEnabled()) {
            setupLocationManager()
        }
        addMeetingsAnnotation(from: friendLocation)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    // RX Setup
    private func setupLocationManager() {

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // Show user and his friend position on the map
    private func showUserAndHisFriendPosition() {
        if locationFirstLoad {
            let deadlineTime = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
                self.map.showAnnotations(self.map.annotations, animated: true)
            }
            locationFirstLoad = false
        } else {
            self.map.showAnnotations(self.map.annotations, animated: true)
        }
    }
    
    // Show proposed meeting locations by adding annotations to map
    private func addMeetingsAnnotation(from coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Place to meet"
        annotation.subtitle = "GOOOOOOOOOOOSIA"
        map.addAnnotation(annotation)
    }
    
    // Zoom map to current user location
    fileprivate func showUserCurrentLocation() {
        if let location = self.userLocation {
            let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            self.map.setRegion(region, animated: true)
        }
    }
    
    //MARK: Actions
    
    @IBAction func centerMapOnUserLocation(_ sender: Any) {
        showUserCurrentLocation()
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        //  Check access for user location
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            showSettingsAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation = location.coordinate
        }
    }
    
    private func showSettingsAlert() {
        // Create the actions buttons for settings alert
        let okAction = UIAlertAction(title: "OK", style: .default) {
            UIAlertAction in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        showAlert(title: "Error",
                  message: "No access to location services. Do you want to change your settings now?",
                  buttonOneTitle: "Go to Settings",
                  cancelButtonTitle: "Cancel",
                  action: okAction)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
