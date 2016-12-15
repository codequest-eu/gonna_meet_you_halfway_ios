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
    func didAcceptInvitation(response: MeetingResponse)
}

let mapLatDelta: CLLocationDegrees = 0.05
let mapLonDelta: CLLocationDegrees = 0.05

class LocationViewController: UIViewController, AlertHandler {

    //MARK: - Outlets
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // MARK: - Properties
    var friendName = ""
    var meetingDetails: MeetingResponse!
    var meetingStatus = Variable(MeetingStatus.pending)
    var getInvitation = false
    var meetingId: String?
    var waitForFriendInvitationResponse = true
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate var locationVM: LocationViewModelProtocol!
    fileprivate let disposeBag = DisposeBag()
    fileprivate var places: [PlaceSuggestion]?
    var friendAccepted = false
    private var locationFirstLoad = true

    //MARK: for test purpose
    var friendLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.436180, -122.395842)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradient(view: view)
        setupMap()
        observeStatusChanges()
        locationVM = LocationViewModel(controller: self)
        guard let location = lm.userLocation.value else {
            if lm.status == .denied {
                showLocationSettingsAlert()
            }
            return
        }
        if let id = meetingId, id != "" {
            meetingStatus.value = .waitingForPlaceSuggestion
            locationVM.acceptInvitation(meetingIdentifier: id, location: location)
        } else {
            locationVM.getPlaceSugestions(from: meetingDetails)
            locationVM.listenForYourFriendSuggestions(from: meetingDetails)
            locationVM.getFriendLocation(from: meetingDetails)
            locationVM.sendUserLocation(location: location, topic: meetingDetails.myLocationTopicName)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserAndHisFriendPosition()
    }
    
    private func setupMap() {
        map.delegate = self
        map.showsScale = true
        map.showsUserLocation = true
        map.clipsToBounds = true
        map.layer.cornerRadius = Globals.cornerRadius
        map.layer.borderColor = UIColor.black.cgColor
        map.layer.borderWidth = 0.7
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
        if let location = self.lm.userLocation.value {
            let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
            let region = MKCoordinateRegion(center: location, span: span)
            map.setRegion(region, animated: true)
        }
    }
    
    //MARK: Actions
    
    @IBAction func centerMapOnUserLocation(_ sender: Any) {
        showUserCurrentLocation()
    }
    
    @IBAction func centerMap(_ sender: Any) {
        showUserAndHisFriendPosition()
    }
}

extension LocationViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Propose place to meet
        guard let coordinates = view.annotation?.coordinate else {
            showError()
            return
        }
        
        let action = UIAlertAction(title: "Send proposal", style: .default, handler: { _ in
            self.locationVM.proposePlaceToMeet(with: self.meetingDetails, coordinates: coordinates)
        })
        showAlert(title: "Alert", message: "Do you want to sent place proposal?", cancelButtonTitle: "Cancel", action: action)
    }
    
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

extension LocationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showError()
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {
        meetingStatus.value = .waitingForPlaceSuggestion
        self.places = places
        addPlacesSuggestionsToMap()
        showUserAndHisFriendPosition()
    }
    
    func didFetchFriendSuggestion(place: MeetingSuggestion) {
        if place.accepted {
            // friend accepted your place suggestion
            showNavivigationController(with: place)
        } else {
            // friend send you place suggestion
            showSuggestionView(for: place)
        }
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        friendLocation = coordinates
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addAnnotation(for: coordinates, image: "friend", title: friendName, subtitle: "")
        addPlacesSuggestionsToMap()
        if !friendAccepted {
            friendAccepted = true
            meetingStatus.value = .waitingForPlaceSuggestion
            showAlert(title: "Success", message: "Your invitation has been accepted!")
            self.map.showAnnotations(self.map.annotations, animated: true)
        }
    }
    
    func didAcceptInvitation(response: MeetingResponse) {
        locationVM.getPlaceSugestions(from: response)
        locationVM.listenForYourFriendSuggestions(from: response)
        locationVM.getFriendLocation(from: response)
        guard let location = lm.userLocation.value else {
            return
        }
        locationVM.sendUserLocation(location: location, topic: response.myLocationTopicName)
    }
    
    private func addPlacesSuggestionsToMap() {
        if let places = self.places {
            for place in places {
                var description = ""
                if let placeDescription = place.description {
                    description = placeDescription
                }
                addAnnotation(for: place.position, image: "place", title: place.name, subtitle: description)
            }
        }
    }
    
    private func showSuggestionView(for place: MeetingSuggestion) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "MeetingSuggestionViewController") as! MeetingSuggestionViewController
        vc.place = place
        vc.friendName = friendName
        vc.proposalAccepted.asObservable()
            .bindNext { (accepted) in
                if accepted {
                    self.showNavivigationController(with: place)
                }
            }
            .addDisposableTo(disposeBag)
        present(vc, animated: true, completion: nil)
    }
    
    private func showNavivigationController(with place: MeetingSuggestion) {
        let showFinalController = UIAlertAction(title: "Great!", style: .default, handler: { _ in
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "NavigationViewController") as! NavigationViewController
            vc.finalPlace = place
            vc.meetingDetails = self.meetingDetails
            vc.friendName = self.friendName
            self.present(vc, animated: true, completion: nil)
        })
        showAlert(title: "Success", message: "\(friendName) has accepted your place suggestion!", action: showFinalController)
    }
}
