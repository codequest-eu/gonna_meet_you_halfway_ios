import WatchKit
import Foundation

class ArrivalInterfaceController: MeetingInfoInterfaceController {
    
    @IBOutlet var myTimeLabel: WKInterfaceLabel!
    @IBOutlet var otherTimeLabel: WKInterfaceLabel!
    
    override var meetingInfo: MeetingInfo? {
        didSet {
            guard let meetingInfo = meetingInfo else { return }
            let myTime = Int(meetingInfo.mine.time)
            let otherTime = Int(meetingInfo.other.time)
            myTimeLabel.setText("\(myTime) min")
            otherTimeLabel.setText("\(otherTime) min")
        }
    }
    
}
