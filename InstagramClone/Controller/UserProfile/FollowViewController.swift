//
//  FollowViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 19/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdenifier = "FollowCell"

class FollowViewController: UITableViewController, FollowCellDelegate {
  
    // MARK: - Properties
    
    var uid: String?
    var users = [User]()
    var isFollowers = false
    var isFollowing = false
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowCell.self, forCellReuseIdentifier: reuseIdenifier)
        
        //c onfigure navigation title
        if isFollowers {
            navigationItem.title = "Followers"
        } else if isFollowing {
            navigationItem.title = "Following"
        }
        
        // configure row height
        tableView.rowHeight = 60
        
        // configure seporator  
        tableView.separatorColor = .clear
        
        //fetch users
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
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdenifier, for: indexPath) as! FollowCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.user = users[indexPath.row]
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    // MARK: - FollowCellDelegate Protocol
    func handleFollowTapped(for cell: FollowCell) {
        guard let user = cell.user else { return }
        
        if user.isFollowed {
            // unfollow user
            user.unfollow()
            cell.configureFollowButton()
            
        } else {
            // follow user
            user.follow()
            cell.configureFollowingButton()
        }
        
    }
    
    // MARK: - Handlers
    
    func fetchUsers() {
        guard let uid = self.uid else { return }

        var ref: DatabaseReference?
        
        if isFollowers {
            ref = USER_FOLLOWERS_REF
        } else if isFollowing {
            ref = USER_FOLLOWING_REF
        }
        
        if let currentRef = ref {
            currentRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    let userId = snapshot.key
                    Database.fetchUser(with: userId, complition: { (user) in
                        
                        self.users.append(user)
                        self.tableView.reloadData()
                        
                    })
                    
                })
                
            }
        }
    }

}
