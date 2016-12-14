import WatchKit
import Foundation


class HomeInterfaceController: WKInterfaceController {

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        WKInterfaceController.reloadRootControllers(withNames: ["Arrival", "Map"], contexts: nil)
    }
    
}
