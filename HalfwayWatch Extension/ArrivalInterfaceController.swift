import WatchKit
import Foundation

class ArrivalInterfaceController: MeetingInfoInterfaceController {
    
    @IBOutlet var myTimeLabel: WKInterfaceLabel!
    @IBOutlet var otherTimeLabel: WKInterfaceLabel!
    
    override var meetingInfo: MeetingInfo? {
        didSet {
            guard let meetingInfo = meetingInfo else { return }
            myTimeLabel.setText(timeInMinutes(from: meetingInfo.mine.time))
            otherTimeLabel.setText(timeInMinutes(from: meetingInfo.other.time))
        }
    }
    
    private func timeInMinutes(from timeInterval: TimeInterval) -> String {
        let totalSeconds = Int(timeInterval)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
}
