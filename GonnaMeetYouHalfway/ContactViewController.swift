//
//  ViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by Michal Karwanski on 12/12/2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import AddressBook
import Contacts
import RxSwift
import RxCocoa



class ContactViewController: UIViewController {

    @IBOutlet weak var userEmailTextField: UITextField!
    @IBOutlet weak var inviteEmailTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var inviteButton: UIButton!
    

    var contactStore = CNContactStore()
    private let disposeBag = DisposeBag()
    private let throttleInterval = 0.1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inviteEmailTextField.delegate = self
        createGradient(view: self.view)
    }
    
    func setupRxObservable() {
        let textField1Text = inviteEmailTextField
            .rx
            .text
            .throttle(throttleInterval, scheduler: MainScheduler.instance)
        
        textField1Text
            .subscribe()
            .addDisposableTo(disposeBag)
    }
    
    
    func checkAddressBookAuthorizationStatus() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        
        switch status {
        case .denied, .restricted:
            
            print("Denied")
        case .authorized:
            
            print("Authorized")
        case .notDetermined:
            
            print("Not Determined")
        }
    }
    
    func requestForAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
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
}

extension ContactViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField)  {
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        requestForAccess { (accessGranted) -> Void in
            if accessGranted {
                let predicate = CNContact.predicateForContacts(matchingName: self.inviteEmailTextField.text!)
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactEmailAddressesKey, CNContactBirthdayKey]
                var filterContacts = [CNContact]()
                var message: String!
                
                let contactsStore = AppDelegate.getAppDelegate().contactStore
                do {
                    let contacts = try contactsStore.unifiedContacts(matching: predicate, keysToFetch: keys as [CNKeyDescriptor])
                    
                    if contacts.count == 0 {
                        message = "No contacts were found matching the given name."
                    }
                    filterContacts = contacts.filter { $0.emailAddresses.count > 0 }
                }
                catch {
                    message = "Unable to fetch contacts."
                }
                
                if message != nil {
                    self.showAlert(title: "Warning", message: message)
                } else {
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchControllerIdentifier") as! SearchContactViewController
                    vc.contacts = filterContacts
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
        return true
    }
}

extension ContactViewController: AddContactViewControllerDelegate {
    
    func didChooseContact(contact: CNContact) {
        //to do: Handle when contact has more than one available mail and send invite
    }
}

