//
//  ViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Contacts
import RxSwift
import RxCocoa

let throttleInterval = 0.1

protocol ContactViewControllerProtocol {
    func didInviteFriendWithSuccess(response: MeetingResponse)
    func didInviteFriendWithFailure()
}

class ContactViewController: UIViewController, AlertHandler {

    //MARK: - Outlets
    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var inviteEmailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inviteButton: UIButton!

    //MARK: - Properties
    var contactStore = CNContactStore()
    var inviteEmail = Variable("")
    var inviteName: String?
    fileprivate let lm = LocationManager.sharedInstance
    fileprivate let disposeBag = DisposeBag()
    fileprivate let inviteEmailTextVariable = Variable("")
    var vm: InviteViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm = InviteViewModel(controller: self)
        inviteEmailTextField.delegate = self
        createGradient(view: self.view)
        setupTextChangeHandling()
    }

    // Validate email format
    fileprivate func isValidEmail(mail: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: mail)
    }
    
    fileprivate func updateButtonState(active: Bool) {
        inviteButton.isEnabled = active
        inviteButton.backgroundColor = active ? Globals.activeButtonColor : Globals.inactiveButtonColor
    }
    
    fileprivate func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
        
        switch authorizationStatus {
        case .denied, .restricted, .notDetermined:
            self.contactStore.requestAccess(for: .contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(access)
                }
                else {
                    if authorizationStatus == .denied {
                        let message = "\(accessError!.localizedDescription)\n\nPlease allow the app to access your contacts through the Settings."
                        self.showAlert(title: "Warning!", message: message)
                        //TODO : Make user available option to go straight to settings
                    }
                }
            })
        case .authorized:
            completionHandler(true)
        }
    }
    
    //MARK: Actions
    @IBAction func invite(_ sender: Any) {
        guard let location = lm.userLocation.value else {
            if lm.status == .denied {
                showLocationSettingsAlert()
            } else {
                showError()
            }
            return
        }
        vm.inviteFriend(name: nameTextField.text!, inviteEmail: inviteEmailTextField.text!, userEmail: userEmailTextField.text!.lowercased(), location: location)
////
////        // FOR TESTS
//        let vc = storyboard?.instantiateViewController(withIdentifier: "NavigationViewController") as! NavigationViewController
////        if let name = inviteName {
////            vc.friendName = name
////        }
//        self.present(vc, animated: true, completion: nil)
    }
    
    func showError(error: Error.Protocol) {
        self.showAlert(title: "Warning", message: "Sorry, an error occured while inviting. Please try again later")
    }
    
    //MARK: - Rx Setup
    func setupTextChangeHandling() {
        
        inviteEmail.asObservable().bindTo(inviteEmailTextField.rx.text).addDisposableTo(disposeBag)
        inviteEmailTextVariable.asObservable().bindTo(inviteEmailTextField.rx.text).addDisposableTo(disposeBag)
        
        let userMailValid = userEmailTextField
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
            .map { self.isValidEmail(mail: $0!) }

        let inviteEmailValid = inviteEmail
            .asObservable()
            .map{ self.isValidEmail(mail: $0) }

        let nameValid = nameTextField
            .rx
            .text
            .map { $0 != "" }
        
        let everythingValid = Observable
            .combineLatest(userMailValid, inviteEmailValid, nameValid) {
                $0 && $1 && $2 // all true
        }
        
        everythingValid
            .bindNext { (isActive) in
                self.updateButtonState(active: isActive)
            }
            .addDisposableTo(disposeBag)
    }
}

extension ContactViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        searchContact()
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func searchContact() {
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let store = CNContactStore()
                store.requestAccess(for: .contacts) { granted, error in
                    guard granted else {
                        return
                    }
                    self.prepareContactData(from: store)
                }
            }
        }
    }
    
    private func prepareContactData(from store: CNContactStore) {
        // get the contacts
        var filterContacts = [CNContact]()
        var contacts = [CNContact]()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey]
        var message: String!
        
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        do {
            try store.enumerateContacts(with: request) { contact, stop in
                contacts.append(contact)
            }
            filterContacts = contacts.filter { $0.emailAddresses.count > 0 }
        } catch {
            message = "Sorry, an error occured."
        }
        
        if message != nil {
            DispatchQueue.main.async {
                self.showAlert(title: "Warning", message: message)
            }
        } else {
            showSearchContactController(with: filterContacts)
        }
    }
    
    private func showSearchContactController(with filterContacts: [CNContact]) {
        OperationQueue.main.addOperation {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchControllerIdentifier") as! SearchContactViewController
            vc.contacts = filterContacts
            vc.searchController.searchBar.text = self.inviteEmail.value
            vc.inviteContact
                .asObservable()
                .bindNext({ (contact) in
                    guard contact.emailAddresses.count == 1 else {
                        if contact.emailAddresses.count > 0  {
                            DispatchQueue.main.async {
                                self.displayAlertForMoreThanOneEmail(with: contact)
                            }
                        }
                        return
                    }
                    self.inviteEmail.value = contact.emailAddresses[0].value as String
                    self.inviteName = contact.givenName
                })
                .addDisposableTo(self.disposeBag)
            
            vc.inviteEmailOutsideAddressbook
                .asObservable()
                .bindTo(self.inviteEmail)
                .addDisposableTo(self.disposeBag)
            
            self.present(vc, animated: true, completion: nil)
        }
    }

    private func displayAlertForMoreThanOneEmail(with contact: CNContact) {
        self.inviteName = contact.givenName
        let email1 = contact.emailAddresses[0].value as String
        let email2 = contact.emailAddresses[1].value as String
        displayActionSheet(email1, buttonOneAction: { _ in
            self.inviteEmail.value = contact.emailAddresses[0].value as String
        }, buttonTwoTitle: email2, buttonTwoAction: { _ in
            self.inviteEmail.value = contact.emailAddresses[1].value as String
        }, cancelAction: nil)
    }
}

extension ContactViewController: ContactViewControllerProtocol {
    
    func didInviteFriendWithSuccess(response: MeetingResponse) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController
        if let name = inviteName {
            vc.friendName = name
        }
        vc.meetingDetails = response
        self.present(vc, animated: true, completion: nil)
    }
    
    func didInviteFriendWithFailure() {
        showError()
    }
}
