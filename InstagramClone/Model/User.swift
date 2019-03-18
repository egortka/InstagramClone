//
//  User.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 14/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Firebase

class User {
    
    var username: String?
    var name: String?
    var profileImageUrl: String?
    var uid: String?
    var isFollowed = false
    
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
    
    //MARK: - follow methods
    
    func follow() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.uid else { return }
        
        // set isFallowed to true
        isFollowed = true
        
        // set followed user to current user following list
        USER_FOLLOWING_REF.child(currentUid).updateChildValues([uid: 1])
        
        // set following user to followed user followers list
        USER_FOLLOWERS_REF.child(uid).updateChildValues([currentUid: 1])
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
    }
    
    func checkIsUserFollowed(complition: @escaping(Bool) -> ()) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let uid = self.uid else { return }
        
        print(uid)
        
        Database.database().reference().child("user-following").child(currentUid).observeSingleEvent(of: .value) { (snapshot) in
            
            print(snapshot)
            if snapshot.hasChild(uid) {
                
                self.isFollowed = true
                complition(true)
                
            } else {
                
                self.isFollowed = false
                complition(false)
                
            }
        }
        
    }
}
