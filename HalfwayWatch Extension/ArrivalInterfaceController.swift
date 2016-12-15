import WatchKit
import Foundation

class ArrivalInterfaceController: MeetingInfoInterfaceController {
    
    @IBOutlet var myTimeLabel: WKInterfaceLabel!
    @IBOutlet var otherTimeLabel: WKInterfaceLabel!
    
    override var meetingInfo: MeetingInfo? {
        didSet {
            guard let meetingInfo = meetingInfo else { return }
            myTimeLabel.setText("\(meetingInfo.myTime) min")
            otherTimeLabel.setText("\(meetingInfo.otherTime) min")
        }
    }
    
}
