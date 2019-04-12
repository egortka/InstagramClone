//
//  Comment.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 30/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Foundation
import Firebase

class Comment {
    
    // MARK: - Properties
    
    var uid: String!
    var commentText: String!
    var creationDate: Date!
    var user: User?
    
    // MARK: - Init
    
    init(with user: User, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let text = dictionary["commentText"] as? String {
            self.commentText = text
        }
        
        if let date = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: date)
        }
    }
    
    // MARK: - Methods
}
