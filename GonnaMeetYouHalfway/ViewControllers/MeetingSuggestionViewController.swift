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
import RxSwift
import RxCocoa

protocol MeetingSuggestionViewControllerProtocol {
    func didPerformRequestWithFailure()
    func userDidAcceptSuggestion()
}

class MeetingSuggestionViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    //MARK: - Properties
    var place: MeetingSuggestion!
    var friendName: String!
    var meetingVM: MeetingViewModelProtocol!
    var proposalAccepted = Variable(false)
    
    // MARK: - Actions
    @IBAction func rejectSuggestion(_ sender: Any) {
        proposalAccepted.value = false
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptSuggestion(_ sender: Any) {
        meetingVM.acceptPlaceSuggestion(placeIdentifier: place.suggestionIdentifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        meetingVM = MeetingViewModel(controller: self)
        setupLabels()
        setupMap()
    }
    
    private func setupLabels() {
        infoLabel.text = "\(friendName) has send you meeting place suggestion!"
        if let name = place.name {
            titleLabel.text = name
        }
        if let description = place.description {
            descriptionLabel.text = description
        }
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

extension MeetingSuggestionViewController: MeetingSuggestionViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        proposalAccepted.value = false
        showAlert(title: "Error", message: "Sorry, an error occured. Please try again.")
    }
    
    func userDidAcceptSuggestion() {
        proposalAccepted.value = true
        dismiss(animated: true, completion: nil)
    }
}
