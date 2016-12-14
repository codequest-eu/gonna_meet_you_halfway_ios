//
//  MeetingSuggestionViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 14.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MeetingSuggestionViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Properties
    var place: MeetingSuggestion!
    var friendName: String!
    
    // MARK: - Actions
    @IBAction func rejectSuggestion(_ sender: Any) {
        
    }
    
    @IBAction func acceptSuggestion(_ sender: Any) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLabels()
        setupMap()
    }
    
    private func setupLabels() {
        infoLabel.text = "\(friendName) has send you meeting place suggestion!"
        titleLabel.text = ""
        descriptionLabel.text = ""
    }
    
    private func setupMap() {
        map.showsScale = true
        map.showsUserLocation = true
        let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
        let region = MKCoordinateRegion(center: coordinates, span: span)
        self.map.setRegion(region, animated: true)
    }
}
