//
//  MeetingStatus.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 14.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

enum MeetingStatus: String {
    case pending = "Waiting for invitation approval"
    case waitingForPlaceSuggestion = "Waiting for place suggestions"
    case waitingForPlaceApproval = "Waiting for place meeting approval"
    case accepted = "Meeting location submitted"
}
