//
//  User.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 14/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Firebase

class User {
    
    // MARK: - Properties
    
    var username: String!
    var name: String!
    var profileImageUrl: String!
    var uid: String!
    var isFollowed = false
    
    // MARK: - Init
    
    init(uid: String, dictionart: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let username = dictionart["username"] as? String {
            self.username = username
        }
        
        if let name = dictionart["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionart["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
    }
    
    //MARK: - Methods
    
    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.uid else { return }
        
        // set isFallowed to true
        isFollowed = true
        
        // set followed user to current user following list
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // set following user to followed user followers list
        USER_FOLLOWERS_REF.child(uid).updateChildValues([currentUid: 1])
        
        // upload follow notification to server
        uploadFollowNotificationToServer()
        
        // add followed user posts to current user feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).updateChildValues([postId : 1])
        }
    }
    
    func unfollow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.uid else { return }
        
        // set isFallowed to false
        isFollowed = false
        
        // set followed user to current user following list
        USER_FOLLOWING_REF.child(currentUid).child(uid).removeValue()
        
        // set following user to followed user followers list
        USER_FOLLOWERS_REF.child(uid).child(currentUid).removeValue()
        
        // remove unfollowed user posts from current user feed
        USER_POSTS_REF.child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            USER_FEED_REF.child(currentUid).child(postId).removeValue()
        }
    }
    
    func checkIsUserFollowed(complition: @escaping(Bool) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.uid else { return }
        
        Database.database().reference().child("user-following").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            if snapshot.hasChild(uid) {
                
                self.isFollowed = true
                complition(true)
                
            } else {
                
                self.isFollowed = false
                complition(false)
                
            }
        }
    }
    
    func uploadFollowNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
    
        let values = ["checked": 0,
                      "creationDate": creationDate,
                      "uid": currentUid,
                      "type": FOLLOW_INT_VALUE] as [String: Any]
        
        NOTIFICATIONS_REF.child(self.uid).childByAutoId().updateChildValues(values)
    }
    
}
