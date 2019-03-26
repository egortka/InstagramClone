//
//  Post.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 22/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Foundation

class Post {
    
    var caption: String!
    var likes: Int!
    var imageUrl: String!
    var ownerUid: String!
    var creationDate: Date!
    var postId: String!
    var user: User?
    
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
    
}
