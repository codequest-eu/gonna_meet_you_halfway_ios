import UIKit
import CoreLocation

struct SuggestionRequest {
    
    let meetingIdentifier: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let name: String?
    let description: String?

}
