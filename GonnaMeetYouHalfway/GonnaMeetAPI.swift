import UIKit
import Moya
import Wrap
import CoreLocation
import ObjectMapper

enum GonnaMeetAPI {

    case createMeeting(request: MeetingRequest)
    case acceptMeeting(request: AcceptMeetingRequest)
    case suggest(suggestion: SuggestionRequest)
    case accept(suggestionIdentifier: String)
    
}

extension GonnaMeetAPI: TargetType {
    
    var baseURL: URL { return URL(string: "http://halfway-29eb2e90.0a374f81.svc.dockerapp.io:8080")! }
//    var baseURL: URL { return URL(string: "http://localhost:8080")! }
    
    var path: String {
        switch self {
        case .createMeeting(_):
            return "/start"
        case .acceptMeeting(_):
            return "/accept_meeting"
        case .suggest(_):
            return "/suggest_meeting_location"
        case .accept(_):
            return "/accept_meeting_location"
        }
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .createMeeting(let request):
            return try! wrap(request)
        case .acceptMeeting(let request):
            return try! wrap(request)
        case .suggest(let suggestion):
            return try! wrap(suggestion)
        case .accept(let suggestionIdentifier):
            return ["identifier" : suggestionIdentifier]
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createMeeting(_), .acceptMeeting(_):
            let response = ["meetingIdentifier": "meetingIdentifier", "topics":
                ["suggestionsTopicName": "UUID-S",
                 "myLocationTopicName": "UUID-A",
                 "otherLocationTopicName": "UUID-B",
                 "meetingLocationTopicName": "UUID-P"
            ]] as [String: Any]
            return try! JSONSerialization.data(withJSONObject: response)
        case .suggest(_):
            return Data()
        case .accept(_):
            return Data()
        }
    }
    
    var task: Task {
        switch self {
        default:
            return .request
        }
    }
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return self.data(using: .utf8)!
    }
}
