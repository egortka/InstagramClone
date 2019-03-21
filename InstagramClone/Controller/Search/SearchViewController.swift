//
//  SearchViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "SearchUserCell"

class SearchViewController: UITableViewController {
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell classess
        tableView.register(SearchUserCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        //table view row height
        tableView.rowHeight = 60
        
        // seporator color
        tableView.separatorColor = .clear
        
        // configure navigation controller
        configureNavigationController()
        
        // fetch users
        fetchUsers()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! SearchUserCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = users[indexPath.row]
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.user = user
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    // MARK: - Handlers
    func configureNavigationController() {
        navigationItem.title = "Explore"
    }
    
    // MARK: - API
    
    func fetchUsers() {
        USERS_REF.observe(.childAdded) { (snapshot) in
            
            let uid = snapshot.key
            Database.fetchUser(with: uid, complition: { (user) in
                self.users.append(user)
                self.tableView.reloadData()
            })
            
        }
    }

}
