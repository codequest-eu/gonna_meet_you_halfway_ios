//
//  LocationViewModel.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import RxSwift
import CoreLocation

protocol LocationViewModelProtocol {
    func proposePlaceToMeet(with details: MeetingResponse, coordinates: CLLocationCoordinate2D)
    func getPlaceSugestions(from details: MeetingResponse)
    func listenForYourFriendSuggestions(from details: MeetingResponse)
    func sendUserLocation(location: CLLocationCoordinate2D, topic: String) 
}

class LocationViewModel: LocationViewModelProtocol {
    
    private let controller: LocationViewControllerProtocol
    private let disposeBag = DisposeBag()
    private let apiProvider = GonnaMeetClient()
    
    init(controller: LocationViewControllerProtocol) {
        self.controller = controller
    }
    
    func proposePlaceToMeet(with details: MeetingResponse, coordinates: CLLocationCoordinate2D) {
        apiProvider.suggest(meetingIdentifier: details.meetingIdentifier, coordinate: coordinates)
            .subscribe(onNext: { response in
                print(response)
            }, onError: { _ in
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
    
    func getPlaceSugestions(from details: MeetingResponse) {
        apiProvider.placeSuggestions(from: details.meetingIdentifier)
            .subscribe(onNext: { (places) in
                self.controller.didFetchPlacesSugestion(places: places)
                print(places)
            }, onError: { _ in
                //TODO: Add error handling when error occurs: for example here user should send invitation again
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
    
    func listenForYourFriendSuggestions(from details: MeetingResponse) {
        apiProvider.meetingSuggestions(from: details.meetingIdentifier)
            .subscribe(onNext: { place in
                self.controller.didFetchFriendSuggestion(place: place)
            }, onError: { _ in
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
    
    func getFriendLocation(from details: MeetingResponse) {
        apiProvider.otherLocations(from: details.otherLocationTopicName)
            .subscribe(onNext: { location in
                let coordinates = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                self.controller.didFetchFriendLocation(coordinates: coordinates)
            }, onError: { _ in
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
    
    func sendUserLocation(location: CLLocationCoordinate2D, topic: String) {
        apiProvider.send(location: location, to: topic)
    }
}
