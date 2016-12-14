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
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate var locationVM: LocationViewModelProtocol!

    override func viewDidLoad() {
        super.viewDidLoad()

        locationVM = LocationViewModel(controller: self)
        locationVM.listenForYourFriendSuggestions(from: meetingDetails)
        guard let location = lm.userLocation else {
            showLocationSettingsAlert()
            return
        }
        locationVM.sendUserLocation(location: location, topic: meetingDetails.myLocationTopicName)
    }

}

extension NavigationViewController: LocationViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        
    }
    
    func didFetchFriendLocation(coordinates: CLLocationCoordinate2D) {
        
    }
    
    func didFetchPlacesSugestion(places: [PlaceSuggestion]) {}
    func didFetchFriendSuggestion(place: MeetingSuggestion) {}
}
