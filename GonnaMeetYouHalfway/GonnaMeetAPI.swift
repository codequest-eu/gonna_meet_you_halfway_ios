import UIKit
import Moya
import Wrap

enum GonnaMeetAPI {

    case createMeeting(request: MeetingRequest)
    
}

extension GonnaMeetAPI: TargetType {
    
    var baseURL: URL { return URL(string: "http://halfway-29eb2e90.0a374f81.svc.dockerapp.io:8080")! }
    
    var path: String {
        switch self {
        case .createMeeting(_):
            return "/start"
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
        }
    }
    
    var sampleData: Data {
        switch self {
        case .createMeeting(_):
            let response = ["suggestionsTopicName": "UDID-S",
                            "myLocationTopicName": "UDID-A",
                            "otherLocationTopicName": "UDID-B",
                            "meetingLocationTopicName": "UDID-P"]
            return try! JSONSerialization.data(withJSONObject: response)
        }
    }
    
    var task: Task {
        switch self {
        case .createMeeting(_):
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
