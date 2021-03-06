//
//  FeedViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "FeedCell"

class FeedViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, FeedCellDelegate {

    // MARK: - Properties
    
    var posts = [Post]()
    var viewSinglePost = false
    var singlePostToPresent: Post?
    
    // MARK: - Init

    override func viewDidLoad() {
        super.viewDidLoad()

        // cegister cell classes
        self.collectionView!.register(FeedCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure refresh controll
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        
        // set background color
        self.collectionView.backgroundColor = .white
        
        // configure logout button
        if !viewSinglePost {
            configureNavigationBar()
        }
        
        //fetchPosts
        if !viewSinglePost {
            fetchPosts()
        }
    }

    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 40 + 8 + 50 + 60
        return CGSize(width: width, height: height)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if viewSinglePost {
            return 1
        } else {
            return posts.count
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FeedCell
        cell.delegate = self
        
        if viewSinglePost {
            if let post = singlePostToPresent {
                cell.post = post
            }
        } else {
            cell.post = posts[indexPath.row]
        }
        return cell
    }

    // MARK: - FeedCellDelegate Protocol
    
    func handleUsernameTapped(for cell: FeedCell) {
        
        guard let user = cell.post?.user else { return }
        
        let userProfileViewController = UserProfileViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileViewController.user = user
        navigationController?.pushViewController(userProfileViewController, animated: true)
    }
    
    func handleOptionsTapped(for cell: FeedCell) {
        print("Cavabanga!")
    }
    
    func handleLikeTapped(for cell: FeedCell, isDoubleTap: Bool) {
        
        guard let post = cell.post else { return }
        
        if post.didLike {
            //handle unlike post
            if !isDoubleTap {
                cell.likeButton.isEnabled = false
                post.adjustLikes(addLike: false) { (likes) in
                    cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                    self.setLikesLabel(for: cell, to: likes)
                    cell.likeButton.isEnabled = true
                }
            }
        } else {
            //handle like post
            cell.likeButton.isEnabled = false
            post.adjustLikes(addLike: true) { (likes) in
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                self.setLikesLabel(for: cell, to: likes)
                cell.likeButton.isEnabled = true
            }
        }
    }
    
    func handleConfigureLikeButton(for cell: FeedCell) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let post = cell.post else { return }
        guard let postId = cell.post?.postId else { return }
        
        USER_LIKES_REF.child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(postId) {
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                post.didLike = true
            } else {
                cell.likeButton.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                post.didLike = false
            }
        }
 
    }
    
    func handleShowLikes(for cell: FeedCell) {
        guard let postId = cell.post?.postId else { return }

        let likesViewController = FollowLikeViewController()
        likesViewController.viewingMode = FollowLikeViewController.ViewingMode(index: 2)
        likesViewController.postID = postId
        navigationController?.pushViewController(likesViewController, animated: true)
    }
    
    
    func handleCommentTapped(for cell: FeedCell) {
        guard let post = cell.post else { return }
        let commentViewController = CommentViewController(collectionViewLayout: UICollectionViewFlowLayout())
        commentViewController.post = post
        navigationController?.pushViewController(commentViewController, animated: true)
    }
    
    // MARK: - Handlers

    @objc func handleRefresh() {
        posts.removeAll(keepingCapacity: false)
        fetchPosts()
        collectionView.reloadData()
    }
    
    @objc func handleLogout() {
        
        // configure alert controller
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { (_) in
            
            do {
                // log out user
                try Auth.auth().signOut()
                
                // present log in screen
                let navigationController = UINavigationController(rootViewController: LoginViewController())
                self.present(navigationController, animated: true, completion: nil)
                
                print("Successfully logged out user")
                
            } catch {
                print("Failed to sign out")
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func handleShowMessages() {
        
    }
    
    func configureNavigationBar() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: #selector(handleShowMessages))
        self.navigationItem.title = "Feed"
    }
    
    func setLikesLabel(for cell: FeedCell, to value: Int) {
        cell.likesLabel.text = "\(value) like"
        if value != 1 {
            cell.likesLabel.text?.append(contentsOf: "s")
        }
    }
    
    // MARK: - API
    
    func fetchPosts() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        USER_FEED_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let postId = snapshot.key
            
            Database.fetchPost(with: postId, complition: { (post) in
                self.posts.append(post)
                
                self.posts.sort(by: { (post1, post2) -> Bool in
                    return post1.creationDate > post2.creationDate
                })
                
                // stop refreshing
                self.collectionView.refreshControl?.endRefreshing()
                
                self.collectionView.reloadData()
            })
        }
    }
}
