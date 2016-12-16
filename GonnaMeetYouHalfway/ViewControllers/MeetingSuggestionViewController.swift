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

class MeetingSuggestionViewController: UIViewController, AlertHandler {

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
        createGradient(view: view)
    }
    
    private func setupLabels() {
        let result: String
        if let name = friendName, name != "" {
            result = name
        } else {
            result = "Your buddy"
        }
        infoLabel.text = "\(result) has sent you meeting place suggestion!"
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
        map.clipsToBounds = true
        map.layer.cornerRadius = 3.0
        let span = MKCoordinateSpanMake(mapLatDelta, mapLonDelta)
        let region = MKCoordinateRegion(center: place.position, span: span)
        self.map.setRegion(region, animated: true)
    }
}

extension MeetingSuggestionViewController: MeetingSuggestionViewControllerProtocol {
    
    func didPerformRequestWithFailure() {
        proposalAccepted.value = false
        showError()
    }
    
    func userDidAcceptSuggestion() {
        proposalAccepted.value = true
        dismiss(animated: true, completion: nil)
    }
}
