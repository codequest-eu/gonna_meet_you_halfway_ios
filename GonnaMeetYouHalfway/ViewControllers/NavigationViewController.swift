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
//    var finalPlace: MeetingSuggestion!
    var friendLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(37.436180, -122.395842)
    
//    var meetingDetails: MeetingResponse!
    var friendName = ""
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate var locationVM: LocationViewModelProtocol!
    fileprivate var myRoute : MKRoute!
    fileprivate let disposeBag = DisposeBag()
    fileprivate var distance: Variable<CLLocationDistance?> = Variable(nil)
    fileprivate var time: Variable<TimeInterval?> = Variable(nil)
    fileprivate var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
        locationVM = LocationViewModel(controller: self)
//        locationVM.getFriendLocation(from: meetingDetails)
        addDestinationAnnotation()
        observeUserLocation()
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
    }
    
    private func observeTimeChanges() {
        time.asObservable()
            .bindNext(setTimeLabel)
            .addDisposableTo(disposeBag)
    }
    
    private func setDirection(userLocation: CLLocationCoordinate2D?) {
        if isFirstLoad {
            //        locationVM.sendUserLocation(location: userLocation, topic: meetingDetails.myLocationTopicName)
            setDirectionRequest()
            observeDistanceChanges()
            observeTimeChanges()
            map.showAnnotations(map.annotations, animated: true)
            isFirstLoad = false
        } else {
            setDirectionRequest()
        }
    }
    
    private func setDistanceLabel(distance: CLLocationDistance?) {
        guard let distanceMeters = distance else {
            return
        }
        destinationDistanceLabel.text = "\(distanceMeters / 1000) km"
    }
    
    private func setTimeLabel(time: TimeInterval?) {
        guard let timeInterval = time else {
            return
        }
        destinationTimeLabel.text = format(timeInterval)
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
//        if let name = finalPlace.name {
//            placeTitle = name
//        } else {
//            placeTitle = "Destination"
//        }
        addAnnotation(for: friendLocation, image: "place", title: placeTitle, subtitle: "")
    }
    
    private func setupMap() {
        map.delegate = self
        map.showsScale = true
        map.showsUserLocation = true
        map.showAnnotations(map.annotations, animated: true)
    }
    
    private func setDirectionRequest() {
        
        guard let userLocation = lm.userLocation.value else {
            return
        }
        
        let directionsRequest = MKDirectionsRequest()
        let user = MKPlacemark(coordinate: CLLocationCoordinate2DMake(userLocation.latitude, userLocation.longitude), addressDictionary: nil)
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2DMake(friendLocation.latitude, friendLocation.longitude), addressDictionary: nil)
        
        directionsRequest.source = MKMapItem(placemark: user)
        directionsRequest.destination = MKMapItem(placemark: destination)
        
        directionsRequest.transportType = MKDirectionsTransportType.automobile
        let directions = MKDirections(request: directionsRequest)
        
        directions.calculate(completionHandler: {
            response, error in
            
            if error == nil {
                self.myRoute = response!.routes[0] as MKRoute
                self.map.add(self.myRoute.polyline)
                if let route = response?.routes.first {
                    self.distance.value = route.distance
                    self.time.value = route.expectedTravelTime
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
        myLineRenderer.strokeColor = UIColor.red
        myLineRenderer.lineWidth = 3
        return myLineRenderer
    }
}


extension NavigationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        showError()
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        map.annotations.forEach { if !($0 is MKUserLocation) { map.removeAnnotation($0) } }
        addAnnotation(for: coordinates, image: "friend", title: friendName, subtitle: "")
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {}
    func didFetchFriendSuggestion(place: MeetingSuggestion) {}
}
