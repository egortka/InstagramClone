//
//  NotificationsViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "NotificationCell"

class NotificationsViewController: UITableViewController, NotificationCellDelegate {

    // MARK: - Properties
    
    var notifications = [Notification]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // clear seporator line
        tableView.separatorStyle = .none
        
        // set navigation title
        navigationItem.title = "Notifications"
        
        // register cell class
        tableView.register(NotificationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        // fetch notifications
        fetchNotifications()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NotificationCell
        cell.notification = notifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.user = notification.user
        
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    // MARK: - NotificationCellDelegate protocol
    func handleFollowTapped(for cell: NotificationCell) {
        
        guard let user = cell.notification?.user else { return }
        
        if user.isFollowed {
            user.unfollow()
            cell.followButton.setTitle("Follow", for: .normal)
            cell.followButton.setTitleColor(.white, for: .normal)
            cell.followButton.layer.borderWidth = 0
            cell.followButton.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.6039215686, blue: 0.9294117647, alpha: 1)
        } else {
            user.follow()
            cell.followButton.setTitle("Following", for: .normal)
            cell.followButton.setTitleColor(.black, for: .normal)
            cell.followButton.layer.borderColor = UIColor.lightGray.cgColor
            cell.followButton.layer.borderWidth = 0.5
            cell.followButton.backgroundColor = .white
        }
        
    }
    
    func handlePostTapped(for cell: NotificationCell) {
        
        guard let post = cell.notification?.post else { return }
        
        let feedViewController = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedViewController.viewSinglePost = true
        feedViewController.singlePostToPresent = post
        navigationController?.pushViewController(feedViewController, animated: true)
    }
    
    // MARK: - API
    
    func fetchNotifications() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        NOTIFICATIONS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            guard let dict = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dict["uid"] as? String else { return }
            
            Database.fetchUser(with: uid, complition: { (user) in
                
                if let postId = dict["postId"] as? String {
                    Database.fetchPost(with: postId, complition: { (post) in
                        
                        let notification = Notification(user: user, post: post, dictionary: dict)
                        self.notifications.append(notification)
                        self.tableView.reloadData()
                    })
                } else {
                    
                    let notification = Notification(user: user, dictionary: dict)
                    self.notifications.append(notification)
                    self.tableView.reloadData()
                }
            })
        }
        
    }
}
