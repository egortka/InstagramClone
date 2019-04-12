//
//  Notification.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 11/04/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Foundation

class Notification {
    
    // MARK: - Properties
    
    enum NotificationType: Int, Printable {
    
        case Like
        case Comment
        case Follow
        
        var description: String {
            
            switch self {
                case .Like: return " liked your post."
                case .Comment: return " commented your post."
                case .Follow: return " started following you."
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            default: self = .Like
            }
        }
    }
    
    var creationDate: Date!
    var uid: String!
    var user: User!
    var postId: String?
    var post: Post?
    var type: Int!
    var notificationType: NotificationType!
    var didCheck = false
    
    //MARK: - Init
    
    init(user: User, post: Post? = nil, dictionary: Dictionary<String, AnyObject>) {
        
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let date = dictionary["creationDate"] as? Double {
            self.creationDate = Date(timeIntervalSince1970: date)
        }
        
        if let uid = dictionary["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dictionary["postId"] as? String {
            self.postId = postId
        }
        
        if let type = dictionary["type"] as? Int {
            self.type = type
            self.notificationType = NotificationType(index: type)
        }
        
        if let checked = dictionary["checked"] as? Int {
            if checked == 0 {
                self.didCheck = false
            } else {
                self.didCheck = true
            }
        }
    }
    
}
