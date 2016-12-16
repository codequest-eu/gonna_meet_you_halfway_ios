//
//  TodayViewController.swift
//  Halfway Widget
//
//  Created by mdziubich on 16.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import NotificationCenter
import MapKit
import CoreLocation
import RxSwift

class TodayViewController: UIViewController, NCWidgetProviding {
    
    // MARK: - Outlets
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var friendTimeLabel: UILabel!
    @IBOutlet weak var friendDistanceLabel: UILabel!
    
    let locationService = LocationInfoService.default
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeLocation()
    }
    
    // Rx Setup
    private func observeLocation() {
        locationService.myLocationInfos
            .asObservable()
            .bindNext(setupUserLabel)
            .addDisposableTo(disposeBag)
        
        locationService.otherLocationInfos
            .asObservable()
        .bindNext(setupFriendLabel)
        .addDisposableTo(disposeBag)
    }
    
    func setupUserLabel(info: LocationInfo) {
        timeLabel.text = format(info.time)
        distanceLabel.text = "\(info.distance / 1000) km"
    }
    
    func setupFriendLabel(info: LocationInfo) {
        timeLabel.text = format(info.time)
        distanceLabel.text = "\(info.distance / 1000) km"
    }
    
    private func format(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.minute, .second]
        
        if duration >= 3600 {
            formatter.allowedUnits.insert(.hour)
            return "\(formatter.string(from: duration)!) h"
        }
        return "\(formatter.string(from: duration)!) min"
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
