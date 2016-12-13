//
//  test.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 13.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import RxSwift

protocol InviteViewModelProtocol {
    func inviteFriend(name: String, inviteEmail: String, userEmail: String)
}

class InviteViewModel: InviteViewModelProtocol {
    
    private let controller: ContactViewControllerProtocol
    private let disposeBag = DisposeBag()
    private let apiProvider = GonnaMeetClient()
    
    init(controller: ContactViewControllerProtocol) {
        self.controller = controller
    }
    
    func inviteFriend(name: String, inviteEmail: String, userEmail: String) {
        apiProvider.requestMeeting(name: name, email: userEmail, otherEmail: inviteEmail)
            .subscribe(onNext: { (response) in
                self.controller.didInviteFriendWithSuccess(response: response)
                print(response)
            }, onError: { (error) in
                self.controller.didInviteFriendWithFailure()
                print(error)
            })
        .addDisposableTo(disposeBag)
    }
}
