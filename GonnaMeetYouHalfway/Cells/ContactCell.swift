//
//  ContactCell.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 12.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import Contacts
import UIKit

class ContactCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!

    func setupLabels(contact: CNContact) {
        nameLabel.text = "\(contact.givenName) \(contact.familyName)"
        emailLabel.text = contact.emailAddresses.map{ "\($0.value)" }.joined(separator: ", ")
    }
}
