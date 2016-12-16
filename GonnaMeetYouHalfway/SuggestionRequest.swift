import UIKit
import CoreLocation

struct SuggestionRequest {
    
    let meetingIdentifier: String
    let position: CLLocationCoordinate2D
    let name: String?
    let description: String?
    let senderLocationTopicName: String

}
