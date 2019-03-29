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
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    var didLike = false
    
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
    
    func adjustLikes(addLike: Bool, completion: @escaping(Int) -> ()) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let postId = self.postId else { return }
        
        if addLike {
            
            // add like to post-like structure
            POST_LIKES_REF.child(postId).updateChildValues([currentUid: 1]) { (error, ref) in
                // add like to user-like structure
                USER_LIKES_REF.child(currentUid).updateChildValues([postId: 1], withCompletionBlock: { (err, ref) in
                    
                    self.likes += 1
                    self.didLike = true
                    completion(self.likes)
                    POSTS_REF.child(self.postId).child("likes").setValue(self.likes)
                })
            }
        } else {
            guard likes > 0 else { return }
            
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
}
