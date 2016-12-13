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
}
