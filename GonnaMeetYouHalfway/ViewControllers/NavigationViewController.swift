//
//  NavigationViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 14.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import RxSwift

class NavigationViewController: UIViewController, AlertHandler {

    // MARK: - Outlets
    @IBOutlet weak var destinationTimeLabel: UILabel!
    @IBOutlet weak var friendDestinationTimeLabel: UILabel!
    @IBOutlet weak var friendInfoLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - Properties
    var finalPlace: MeetingSuggestion!
    var meetingDetails: MeetingResponse!
    var friendName = ""
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate var locationVM: LocationViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        locationVM = LocationViewModel(controller: self)
        locationVM.getFriendLocation(from: meetingDetails)

        guard let location = lm.userLocation else {
            showLocationSettingsAlert()
            return
        }
        locationVM.sendUserLocation(location: location, topic: meetingDetails.myLocationTopicName)
    }
    
    private func setupMap() {
        map.delegate = self
        map.showsScale = true
        map.showsUserLocation = true
    }

    // Show friend location
    fileprivate func addFriendAnnotation(for place: CLLocationCoordinate2D) {
        let annotation = GonnaMeetAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        annotation.title = friendName
        annotation.subtitle = ""
        annotation.imageName = "friend"
        map.addAnnotation(annotation)
    }
}

extension NavigationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is GonnaMeetAnnotation) {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        annotationView.isEnabled = true
        annotationView.canShowCallout = true
        
        let btn = UIButton(type: .contactAdd)
        annotationView.rightCalloutAccessoryView = btn
        
        let gma = annotation as! GonnaMeetAnnotation
        let image = UIImage(named: gma.imageName)
        
        annotationView.image = image
        
        return annotationView
    }
}


extension NavigationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showError()
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addFriendAnnotation(for: coordinates)
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {}
    func didFetchFriendSuggestion(place: MeetingSuggestion) {}
}
