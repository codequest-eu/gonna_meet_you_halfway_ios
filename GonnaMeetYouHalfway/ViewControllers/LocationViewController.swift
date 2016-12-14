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

protocol LocationViewControllerProtocol {
    func didPerformRequestWithFailure()
    func didFetchPlacesSugestion(places: [PlaceSuggestion])
}

class LocationViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var friendName = ""
    var meetingDetails: MeetingResponse!
    private var locationFirstLoad = true
    let lm = LocationManager.sharedInstance
    let mapLatDelta: CLLocationDegrees = 0.05
    let mapLonDelta: CLLocationDegrees = 0.05
    var locationVM: LocationViewModelProtocol!
    
    //MARK: for test purpose
    var friendLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.436180, -122.395842)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        map.showsScale = true
        map.showsUserLocation = true
//        addMeetingsAnnotation(for: friendLocation)
        locationVM = LocationViewModel(controller: self)
        locationVM.getPlaceSugestions(from: meetingDetails)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserAndHisFriendPosition()
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
    fileprivate func addMeetingsAnnotation(for place: PlaceSuggestion) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        annotation.title = place.name
        annotation.subtitle = place.description
        map.addAnnotation(annotation)
    }
    
    // Zoom map to current user location
    fileprivate func showUserCurrentLocation() {
        if let location = self.lm.userLocation {
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

extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Propose place to meet
        locationVM.proposePlaceToMeet(with: meetingDetails, coordinates: friendLocation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        
        let btn = UIButton(type: .contactAdd)
        annotationView.rightCalloutAccessoryView = btn
        return annotationView
    }
}

extension LocationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showAlert(title: "Error", message: "Sorry, an error occured. Please try again later")
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {
        for place in places {
            addMeetingsAnnotation(for: place)
        }
    }
}
