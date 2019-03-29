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

class FollowLikeViewController: UITableViewController, FollowCellDelegate {
  
    // MARK: - Properties
    
    enum ViewingMode: Int {
        
        case Following
        case Followers
        case Likes
        
        init(index: Int) {
            
            switch index {
            case 0: self = .Following
            case 1: self = .Followers
            case 2: self = .Likes
            default: self = .Following
            }
        }
    }
    var viewingMode: ViewingMode?
    var users = [User]()
    var uid: String?
    var postID: String?
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell class
        tableView.register(FollowLikeCell.self, forCellReuseIdentifier: reuseIdenifier)
        
        // configure navigation title
        configureNavigationTitle()
        
        // fetch users
        fetchUsers()
            
        // configure row height
        tableView.rowHeight = 60
        
        // configure seporator  
        tableView.separatorColor = .clear
        
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdenifier, for: indexPath) as! FollowLikeCell
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
    func handleFollowTapped(for cell: FollowLikeCell) {
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
    
    func configureNavigationTitle() {
        
        guard let viewingMode = self.viewingMode else { return }
        
        switch viewingMode {
        case .Followers: navigationItem.title = "Followers"
        case .Following: navigationItem.title = "Following"
        case .Likes: navigationItem.title = "Likes"
        }
    }
    
    func getDatabaseRef() -> DatabaseReference? {
        
        guard let viewingMode = self.viewingMode else { return nil }
        
        switch viewingMode {
        case .Followers: return USER_FOLLOWERS_REF
        case .Following: return USER_FOLLOWING_REF
        case .Likes: return POST_LIKES_REF
        }
        
        
    }
    
    func getUsers(from snapshot: DataSnapshot) {
        let userId = snapshot.key
        Database.fetchUser(with: userId, complition: { (user) in
            
            self.users.append(user)
            self.tableView.reloadData()
            
        })
    }
    
    func fetchUsers() {
        
        guard let viewingMode = self.viewingMode else { return }
        guard let currentRef = getDatabaseRef() else { return }
        
        switch viewingMode {
        case .Followers, .Following:
            guard let uid = self.uid else { return }
            
            currentRef.child(uid).observeSingleEvent(of: .value) { (snapshot) in
                
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }
                
                allObjects.forEach({ (snapshot) in
                    
                    self.getUsers(from: snapshot)
                })
                
            }
    
        case .Likes:
            guard let postId = self.postID else { return }
            
            currentRef.child(postId).observe(.childAdded) { (snapshot) in
                
                self.getUsers(from: snapshot)
            }
            
        }
    }

}
