//
//  MeetingViewModel.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 14.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import RxSwift
import CoreLocation

protocol MeetingViewModelProtocol {
    func acceptPlaceSuggestion(placeIdentifier: String)
}

class MeetingViewModel: MeetingViewModelProtocol {
    
    private let controller: MeetingSuggestionViewControllerProtocol
    private let disposeBag = DisposeBag()
    private let apiProvider = GonnaMeetClient()
    
    init(controller: MeetingSuggestionViewControllerProtocol) {
        self.controller = controller
    }
    
    func acceptPlaceSuggestion(placeIdentifier: String) {
        apiProvider.accept(suggestionIdentifier: placeIdentifier)
            .subscribe(onNext: { (response) in
                print(response)
                self.controller.userDidAcceptSuggestion()
            }, onError: { _ in
                self.controller.didPerformRequestWithFailure()
            })
            .addDisposableTo(disposeBag)
    }
}

