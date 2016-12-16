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
    @IBOutlet weak var destinationDistanceLabel: UILabel!
    @IBOutlet weak var friendDestinationTimeLabel: UILabel!
    @IBOutlet weak var friendDestinationDistanceLabel: UILabel!
    @IBOutlet weak var friendInfoLabel: UILabel!
    
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - Properties
    var finalPlace: MeetingSuggestion!
    var friendLocation: Variable<CLLocationCoordinate2D?> = Variable(nil)
    //TEST
//    var friendLocation: Variable<CLLocationCoordinate2D> = Variable(CLLocationCoordinate2DMake(37.436180, -122.395842))
//    var finalPlace: Variable<CLLocationCoordinate2D> = Variable(CLLocationCoordinate2DMake(36.58, -122.1))
    
    var meetingDetails: MeetingResponse!
    var friendName = ""
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate var locationVM: LocationViewModelProtocol!
    fileprivate var myRoute : GonnaMeetRoute!
    fileprivate let disposeBag = DisposeBag()
    fileprivate var distance: Variable<CLLocationDistance?> = Variable(nil)
    fileprivate var time: Variable<TimeInterval?> = Variable(nil)
    fileprivate var friendDistance: Variable<CLLocationDistance?> = Variable(nil)
    fileprivate var friendTime: Variable<TimeInterval?> = Variable(nil)
    fileprivate var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        locationVM = LocationViewModel(controller: self)
        locationVM.getFriendLocation(from: meetingDetails)
        addDestinationAnnotation()
        observeUserLocation()
        observeFriendLocation()
        createGradient(view: view)
    }
    
    // MARK: - RxSetup
    private func observeUserLocation() {
        lm.userLocation.asObservable()
            .bindNext(setDirection)
            .addDisposableTo(disposeBag)
    }
    
    private func observeDistanceChanges() {
        distance.asObservable()
            .bindNext(setDistanceLabel)
            .addDisposableTo(disposeBag)
        
        friendDistance.asObservable()
            .bindNext(setFriendDistanceLabel)
            .addDisposableTo(disposeBag)
    }
    
    private func observeTimeChanges() {
        time.asObservable()
            .bindNext(setTimeLabel)
            .addDisposableTo(disposeBag)
        
        friendTime.asObservable()
            .bindNext(setFriendTimeLabel)
            .addDisposableTo(disposeBag)
    }
    
    private func observeFriendLocation() {
        friendLocation.asObservable()
            .filterNil()
            .bindNext(updateFriendLocation)
            .addDisposableTo(disposeBag)
    }
    
    private func setDirection(userLocation: CLLocationCoordinate2D?) {
        if isFirstLoad {
            //        locationVM.sendUserLocation(location: userLocation, topic: meetingDetails.myLocationTopicName)
            setDirectionRequest(for: userLocation!, userType: .user)
            observeDistanceChanges()
            observeTimeChanges()
            map.showAnnotations(map.annotations, animated: true)
            isFirstLoad = false
        } else {
            setDirectionRequest(for: userLocation!, userType: .user)
        }
    }
    
    private func updateFriendLocation(coordinates: CLLocationCoordinate2D?) {
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addAnnotation(for: coordinates!, image: "friend", title: friendName, subtitle: "")
        addDestinationAnnotation()
        setDirectionRequest(for: coordinates!, userType: .friend)
    }
    
    private func setDistanceLabel(distance: CLLocationDistance?) {
        guard let distanceMeters = distance else {
            return
        }
        destinationDistanceLabel.text = "\(distanceMeters / 1000) km"
    }
    
    private func setFriendDistanceLabel(distance: CLLocationDistance?) {
        guard let distanceMeters = distance else {
            return
        }
        friendDestinationDistanceLabel.text = "\(distanceMeters / 1000) km"
    }
    
    private func setTimeLabel(time: TimeInterval?) {
        guard let timeInterval = time else {
            return
        }
        destinationTimeLabel.text = format(timeInterval)
    }
    
    private func setFriendTimeLabel(time: TimeInterval?) {
        guard let timeInterval = time else {
            return
        }
        friendDestinationTimeLabel.text = format(timeInterval)
    }
    
    private func format(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        if duration >= 3600 {
            formatter.allowedUnits.insert(.hour)
            return "\(formatter.string(from: duration)!) h"
        }
        return "\(formatter.string(from: duration)!) min"
    }
    
    private func addDestinationAnnotation() {
        var placeTitle = ""
        if let name = finalPlace.name {
            placeTitle = name
        } else {
            placeTitle = "Destination"
        }
        addAnnotation(for: finalPlace.position, image: "place", title: placeTitle, subtitle: "")
        //TEST
//        addAnnotation(for: finalPlace.value, image: "place", title: placeTitle, subtitle: "")
    }
    
    private func setupMap() {
        map.delegate = self
        map.showsScale = true
        map.clipsToBounds = true
        map.layer.cornerRadius = 3.0
        map.layer.borderWidth = 0.5
        map.layer.borderColor = UIColor.black.cgColor
        map.showsUserLocation = true
        map.showAnnotations(map.annotations, animated: true)
    }
    
    private func setDirectionRequest(for startPoint: CLLocationCoordinate2D, userType: UserType) {
        
        let directionsRequest = MKDirectionsRequest()
        let start = MKPlacemark(coordinate: CLLocationCoordinate2DMake(startPoint.latitude, startPoint.longitude), addressDictionary: nil)
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(finalPlace.position.latitude, finalPlace.position.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: start)
        directionsRequest.destination = MKMapItem(placemark: destination)
        
        directionsRequest.transportType = MKDirectionsTransportType.automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate(completionHandler: {
            response, error in
            
            if error == nil {
                self.myRoute = GonnaMeetRoute(userType: userType, polyline: response!.routes[0].polyline)
                self.myRoute.userType = userType
                self.map.add(self.myRoute.polyline)
                if let route = response?.routes.first {
                    switch userType {
                    case .user:
                        self.distance.value = route.distance
                        self.time.value = route.expectedTravelTime
                    case .friend:
                        self.friendDistance.value = route.distance
                        self.friendTime.value = route.expectedTravelTime
                    }
                }
            }
        })
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
    
    // MARK: - Actions:
    @IBAction func centerMap(_ sender: Any) {
        map.showAnnotations(map.annotations, animated: true)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let myLineRenderer = MKPolylineRenderer(polyline: myRoute.polyline)
        if myRoute.userType == .user {
            myLineRenderer.strokeColor = UIColor.red
        } else {
            myLineRenderer.strokeColor = UIColor.blue
        }
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
}


extension NavigationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showError()
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        friendLocation.value = coordinates
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {}
    func didFetchFriendSuggestion(place: MeetingSuggestion) {}
    func didAcceptInvitation(response: MeetingResponse) {}
}
