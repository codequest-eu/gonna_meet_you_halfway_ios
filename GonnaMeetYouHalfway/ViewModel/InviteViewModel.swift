//
//  test.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import RxSwift
import CoreLocation

protocol InviteViewModelProtocol {
    func inviteFriend(name: String, inviteEmail: String, userEmail: String, location: CLLocationCoordinate2D)
}

class InviteViewModel: InviteViewModelProtocol {
    
    private let controller: ContactViewControllerProtocol
    private let disposeBag = DisposeBag()
    private let apiProvider = GonnaMeetClient()
    
    private let locationInfoService: LocationInfoService
    
    init(controller: ContactViewControllerProtocol, locationInfoService: LocationInfoService = LocationInfoService.default) {
        self.controller = controller
        self.locationInfoService = locationInfoService
    }
    
    func inviteFriend(name: String, inviteEmail: String, userEmail: String, location: CLLocationCoordinate2D) {
        apiProvider.requestMeeting(name: name, email: userEmail, otherEmail: inviteEmail, location: location)
            .subscribe(onNext: { (response) in
                self.controller.didInviteFriendWithSuccess(response: response)
                self.locationInfoService.meetingResponse.value = response
                print(response)
            }, onError: { (error) in
                self.controller.didInviteFriendWithFailure()
                print(error)
            })
        .addDisposableTo(disposeBag)
    }
}
