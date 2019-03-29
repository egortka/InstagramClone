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
    var posts = [Post]()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UserPostCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerIdentifier)

        // Background color
        self.collectionView.backgroundColor = .white
        
        // fetch user data
        if self.user == nil {
            fetchCurrentUserData()
        }
        
        // fetch posts
        fetchPosts()
    }

    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }

    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return posts.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserPostCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // configure header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        
        header.delegate = self
        
        header.user = self.user
        navigationItem.title = user?.username
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feedViewController = FeedViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        feedViewController.viewSinglePost = true
        feedViewController.singlePostToPresent = posts[indexPath.item]
        
        navigationController?.pushViewController(feedViewController, animated: true)
    }
    
    // MARK: - UserProfileHeader protocol
    
    func handleFollowersTapped(for header: UserProfileHeader) {
        let followViewController = FollowLikeViewController()
        followViewController.uid = self.user?.uid
        followViewController.viewingMode = FollowLikeViewController.ViewingMode(index: 1)
        navigationController?.pushViewController(followViewController, animated: true)
    }
    
    func handleFollowingTapped(for header: UserProfileHeader) {
        let followViewController = FollowLikeViewController()
        followViewController.uid = self.user?.uid
        followViewController.viewingMode = FollowLikeViewController.ViewingMode(index: 0)
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
    
    func fetchPosts() {
        var currentUid: String!
        
        if let user = self.user {
            currentUid = user.uid
        } else {
            currentUid = Auth.auth().currentUser?.uid
        }
        
        USER_POSTS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
   
            let postId = snapshot.key
            Database.fetchPost(with: postId, complition: { (post) in
                self.posts.append(post)
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                self.collectionView.reloadData()
            })
            
        }
    }
}
