//
//  User.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 14/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

struct User {
    
    var userName: String?
    var name: String?
    var profileImageUrl: String?
    var uid: String?
    
    init(uid: String, dictionart: Dictionary<String, AnyObject>) {
        
        self.uid = uid
        
        if let userName = dictionart["userName"] as? String {
            self.userName = userName
        }
        
        if let name = dictionart["name"] as? String {
            self.name = name
        }
        
        if let profileImageUrl = dictionart["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
        
    }
    
}
