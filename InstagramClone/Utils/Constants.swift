//
//  Constants.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 18/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import Firebase

//MARK: - Root references

let DB_REF = Database.database().reference()
let STORAGE_REF = Storage.storage().reference()

//MARK: - Storage references

let STORAGE_PROFILE_IMAGES_REF = STORAGE_REF.child("profile_images")
let STORAGE_POSTS_IMAGES_RES = STORAGE_REF.child("post_images")

//MARK: - Database References

let USERS_REF = DB_REF.child("users")

let USER_FOLLOWERS_REF = DB_REF.child("user-followers")
let USER_FOLLOWING_REF = DB_REF.child("user-following")

let POSTS_REF = DB_REF.child("posts")
let USER_POSTS_REF = DB_REF.child("user-posts")

let USER_FEED_REF = DB_REF.child("user-feed")
