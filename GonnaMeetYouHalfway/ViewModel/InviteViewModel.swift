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
    
    let controller: ContactViewControllerProtocol
    
    init(controller: ContactViewControllerProtocol) {
        self.controller = controller
    }
    
    fileprivate let disposeBag = DisposeBag()
    private let apiProvider = GonnaMeetProvider()
    
    func inviteFriend(name: String, inviteEmail: String, userEmail: String) {
        apiProvider.requestMeeting(name: name, email: userEmail, inviteEmail: inviteEmail)
            .subscribe(onNext: { (response) in
                self.controller.didInviteFriendWithSuccess()
                print(response)
            }, onError: { (error) in
                self.controller.didInviteFriendWithFailure()
                print(error)
            })
        .addDisposableTo(disposeBag)
    }
}
