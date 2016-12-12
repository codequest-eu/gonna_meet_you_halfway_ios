//
//  SearchContactViewController.swift
//  GonnaMeetYouHalfway
//
//  Created by mdziubich on 12.12.2016.
//  Copyright © 2016 Codequest. All rights reserved.
//

import UIKit
import Contacts

class SearchContactViewController: UIViewController {

    var contacts = [CNContact]()
    var filteredContacts = [CNContact]()
    let searchController = UISearchController(searchResultsController: nil)
    var inviteContact = CNContact()
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
    }

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredContacts.removeAll()
        let searchPredicate = NSPredicate(format: "inviteContact CONTAINS[c] %@", searchText)
        let array = (contacts as NSArray).filtered(using: searchPredicate)
        filteredContacts = array as! [CNContact]
//        
//        filteredContacts = contacts.filter { contact in
//            return contact.emailAddresses.contains(searchText)
//            return contact.emailAddresses.lowercased().containsString(searchText.lowercased())
//        }
//
        tableView.reloadData()
    }

}

extension SearchContactViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}

extension SearchContactViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredContacts.count
        }
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath) as! ContactCell
        
        let contact: CNContact
        if searchController.isActive && searchController.searchBar.text != "" {
            contact = filteredContacts[indexPath.row]
        } else {
            contact = contacts[indexPath.row]
        }
        cell.setupLabels(contact: contact)
        
        return cell
    }
}

extension SearchContactViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
