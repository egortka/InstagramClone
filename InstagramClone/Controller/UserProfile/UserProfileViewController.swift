//
//  UserProfileViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, UserProfileHeaderDelegate {
  
    // MARK: - Properties
    
    var user: User?
   // var userToLoadFromSearch: User?
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerIdentifier)

        // Background color
        self.collectionView.backgroundColor = .white
        
        // fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
    }


    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // configure header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        
        header.user = self.user
        navigationItem.title = user?.username
        
        return header
    }
    
    // MARK: - UserProfileHeader protocol
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followViewController = FollowViewController()
        followViewController.uid = self.user?.uid
        followViewController.isFollowers = true
        navigationController?.pushViewController(followViewController, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followViewController = FollowViewController()
        followViewController.uid = self.user?.uid
        followViewController.isFollowing = true
        navigationController?.pushViewController(followViewController, animated: true)
    }
    
    func handleEditFollowTapped(for header: UserProfileHeader) {
        guard let user = header.user else { return }
        
        // handle user follow/unfollow
        if header.editProfileFollowButton.titleLabel?.text == "Follow" {
            header.editProfileFollowButton.setTitle("Following", for: .normal)
            user.follow()
        } else if header.editProfileFollowButton.titleLabel?.text == "Following" {
            header.editProfileFollowButton.setTitle("Follow", for: .normal)
            user.unfollow()
        }
    }
    
    func setUserStats(for header: UserProfileHeader) {
        guard let uid = header.user?.uid else { return }
        
        var numerOfFollowers = 0
        var numberOfFollowing = 0
        
        // get number of followers
        USER_FOLLOWERS_REF.child(uid).observe(.value) { (snapshot) in
            if let followers = snapshot.value as? Dictionary<String, AnyObject> {
                numerOfFollowers = followers.count
            } else {
                numerOfFollowers = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numerOfFollowers)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "followers", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followersLabel.attributedText = attributedText
        }
        
        // get number of following
        USER_FOLLOWING_REF.child(uid).observe(.value) { (snapshot) in
            if let followers = snapshot.value as? Dictionary<String, AnyObject> {
                numberOfFollowing = followers.count
            } else {
                numberOfFollowing = 0
            }
            let attributedText = NSMutableAttributedString(string: "\(numberOfFollowing)\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedText.append(NSAttributedString(string: "following", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
            header.followingLabel.attributedText = attributedText
        }
    }
    
    // MARK: - API
    
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USERS_REF.child(currentUid).observeSingleEvent(of: .value) { (snapShot) in
            guard let userDictionary = snapShot.value as? Dictionary<String, AnyObject> else { return }
            
            let uid = snapShot.key
            let user = User(uid: uid, dictionart: userDictionary)
            
            self.navigationItem.title = user.username
            self.user = user
            self.collectionView.reloadData()
            
        }
    }
}
