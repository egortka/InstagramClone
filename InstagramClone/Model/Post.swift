//
//  Post.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 22/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    // MARK: - Properties
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
    // MARK: - Init
    
    init(user: User, postId: String, dictionary: Dictionary<String, AnyObject>) {
        
        self.postId = postId
        
        self.user = user
        
        if let likes = dictionary["likes"] as? Int {
            self.likes = likes
        }
        
        if let ownerUid = dictionary["ownerUid"] as? String {
            self.ownerUid = ownerUid
        }
        
        if let creatinoDate = dictionary["creationDate"] as? Int {
            self.creationDate = Date(timeIntervalSince1970: Double(creatinoDate))
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self.imageUrl = imageUrl
        }
        
        if let caption = dictionary["caption"] as? String {
            self.caption = caption
        }
    }
    
    // MARK: - Methods
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            
            // add like to post-like structure
            POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1]) { (error, ref) in
                // add like to user-like structure
                USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                    // send notification to server
                    self.sendLikeNotificationToServer()
                    
                    self.likes += 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                })
            }
        } else {
            
            // remove like
            guard likes > 0 else { return }
            
            USER_LIKES_REF.child(currentUid).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                // notification id to remove
                if let notificationId = snapshot.value as? String {
                    // remove notification
                    NOTIFICATIONS_REF.child(self.ownerUid).child(notificationId).removeValue()
                }
            }
            // remove like from post-like structure
            POST_LIKES_REF.child(self.postId).child(currentUid).removeValue { (err, ref) in
                // remove like from user-like structure
                USER_LIKES_REF.child(currentUid).child(self.postId).removeValue(completionBlock: { (err, ref) in
                    
                    self.likes -= 1
                    self.didLike = false
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                })
            }
        }
    }
    
    func sendLikeNotificationToServer() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        
        if currentUid != self.ownerUid {
            
            let values = ["checked": 0,
                          "creationDate": creationDate,
                          "uid": currentUid,
                          "type": LIKE_INT_VALUE,
                          "postId": postId] as [String: Any]
            
            let notificationRef = NOTIFICATIONS_REF.child(self.ownerUid).childByAutoId()
            notificationRef.updateChildValues(values) { (err, ref) in
                USER_LIKES_REF.child(currentUid).child(self.postId).setValue(notificationRef.key)
            }
        }
    }
}
