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
    
    func acceptPlaceSuggestion(placeIdentifier: String) {
        apiProvider.accept(suggestionIdentifier: placeIdentifier)
            .subscribe(onNext: { (response) in
                print(response)
            }, onError: { _ in
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
}
