import WatchKit
import Foundation

class MeetingInfoInterfaceController: WKInterfaceController {

    var meetingInfo: MeetingInfo?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let delegate = context as? MeetingInfoInterfaceControllerDelegate else { return }
        delegate.meetingInfoInterfaceControllerDidWakeUp(self)
    }
    
}

protocol MeetingInfoInterfaceControllerDelegate {
    
    func meetingInfoInterfaceControllerDidWakeUp(_ controller: MeetingInfoInterfaceController)
    
}
