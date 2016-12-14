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
    func didFetchFriendSuggestion(place: MeetingSuggestion)
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D)
}

let mapLatDelta: CLLocationDegrees = 0.05
let mapLonDelta: CLLocationDegrees = 0.05

class LocationViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var showDirectionsButton: UIButton!
    
    // MARK: - Properties
    var friendName = ""
    var meetingDetails: MeetingResponse!
    private var locationFirstLoad = true
    let lm = LocationManager.sharedInstance
    var locationVM: LocationViewModelProtocol!
    var meetingStatus = Variable(MeetingStatus.pending)
    fileprivate let disposeBag = DisposeBag()

    
    //MARK: for test purpose
    var friendLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.436180, -122.395842)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        map.delegate = self
        map.showsScale = true
        map.showsUserLocation = true
        addAnnotation(for: friendLocation, image: "friend", title: "GOOOSAI", subtitle: "GOSIA")
        locationVM = LocationViewModel(controller: self)
        observeStatusChanges()
//        locationVM.getPlaceSugestions(from: meetingDetails)
//        locationVM.listenForYourFriendSuggestions(from: meetingDetails)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserAndHisFriendPosition()
    }
    
    //MARK: - RxSetup
    func observeStatusChanges() {
        meetingStatus
            .asObservable()
            .subscribe(onNext: updateLabel)
            .addDisposableTo(disposeBag)
    }
    
    private func updateLabel(with status: MeetingStatus) {
        statusLabel.text = status.rawValue
        showDirectionsButton.isHidden = !(status == .accepted)
    }

    // Show user and his friend position on the map
    fileprivate func showUserAndHisFriendPosition() {
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
    fileprivate func addAnnotation(for place: CLLocationCoordinate2D, image: String, title: String, subtitle: String) {
        let annotation = GonnaMeetAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.imageName = image
        map.addAnnotation(annotation)
    }
    
    // Zoom map to current user location
    fileprivate func showUserCurrentLocation() {
        if let location = self.lm.userLocation {
            let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    //MARK: Actions
    
    @IBAction func centerMapOnUserLocation(_ sender: Any) {
        showUserCurrentLocation()
    }
    
    @IBAction func showDirections(_ sender: Any) {
        
    }
}

extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Propose place to meet
        locationVM.proposePlaceToMeet(with: meetingDetails, coordinates: friendLocation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is GonnaMeetAnnotation) {
            return nil
        }
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: nil) //MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
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

extension LocationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showAlert(title: "Error", message: "Sorry, an error occured. Please try again later")
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {
        meetingStatus.value = .waitingForPlaceSuggestion
        for place in places {
            var description = ""
            if let placeDescription = place.description {
                description = placeDescription
            }
            let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
            addAnnotation(for: coordinates, image: "place", title: place.name, subtitle: description)
        }
    }
    
    func didFetchFriendSuggestion(place: MeetingSuggestion) {
        if place.accepted {
            // friend accepted your place suggestion
            configureView(with: place)
        } else {
            // friend send you place suggestion
            showSuggestionView(for: place)
        }
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        friendLocation = coordinates
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addAnnotation(for: coordinates, image: "friend", title: friendName, subtitle: "")
    }
    
    private func showSuggestionView(for place: MeetingSuggestion) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MeetingSuggestionViewController") as! MeetingSuggestionViewController
        vc.place = place
        vc.friendName = friendName
        present(vc, animated: true, completion: nil)
    }
    
    private func configureView(with place: MeetingSuggestion) {
        showAlert(title: "Success", message: "\(friendName) has accepted your place suggestion!")
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addAnnotation(for: friendLocation, image: "friend", title: friendName, subtitle: "")
        
        let placeCoordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        addAnnotation(for: placeCoordinates, image: "", title: place.name!, subtitle: place.description!)
        meetingStatus.value = .accepted
        showUserAndHisFriendPosition()
    }
}
