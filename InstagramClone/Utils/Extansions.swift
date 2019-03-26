//
//  Extansions.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 12/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

extension UIView{
    
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

extension Database {
    
    static func fetchUser(with uid: String, complition: @escaping(User) -> ()) {
        
        USERS_REF.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? Dictionary<String, AnyObject> else { return }
            
            let user = User(uid: uid, dictionart: dict)
            complition(user)
        }
        
    }
    
    static func fetchPost(with postId: String, complition: @escaping(Post) -> ()) {
        POSTS_REF.child(postId).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dict = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let ownerUid = dict["ownerUid"] as? String else { return }
            
            Database.fetchUser(with: ownerUid, complition: { (user) in
                let post = Post(user: user, postId: postId, dictionary: dict)
                complition(post)
            })
            
        }
    }
    
}
