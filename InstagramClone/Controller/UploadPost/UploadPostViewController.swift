//
//  UploadPostViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

class UploadPostViewController: UIViewController, UITextViewDelegate {

    // MARK: - Properties
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    let captionTextView: UITextView = {
        let caption = UITextView()
        caption.backgroundColor = UIColor.groupTableViewBackground
        caption.font = UIFont.systemFont(ofSize: 14)
        return caption
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Share", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8, blue: 0.9568627451, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleSharePost), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set UITextView delegate
        
        captionTextView.delegate = self
        
        // set background color
        view.backgroundColor = .white
        
        // configure photo view
        view.addSubview(photoImageView)
        photoImageView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 0, width: 100, height: 100)
        
        // configure caption view
        view.addSubview(captionTextView)
        captionTextView.anchor(top: view.topAnchor, left: photoImageView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 92, paddingLeft: 12, paddingBottom: 0, paddingRight: 12, width: 0, height: 100)
        
        // configure share button
        view.addSubview(shareButton)
        shareButton.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 12, paddingLeft: 24, paddingBottom: 0, paddingRight: 24, width: 0, height: 40)

    }
    
    // MARK: - UITextView
    func textViewDidChange(_ textView: UITextView) {
        guard !textView.text.isEmpty else {
            shareButton.isEnabled = false
            shareButton.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8, blue: 0.9568627451, alpha: 1)
            return
        }
        shareButton.isEnabled = true
        shareButton.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.6039215686, blue: 0.9294117647, alpha: 1)
    }
    
    // MARK: - Handlers
    
    func updateUserFeeds(with postId: String) {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        // data to add
        let value = [postId: 1]
        
        USER_FOLLOWERS_REF.child(currentUid).observe(.childAdded) { (snapshot) in
            
            let followerUid = snapshot.key
            USER_FEED_REF.child(followerUid).updateChildValues(value)
        }
        USER_FEED_REF.child(currentUid).updateChildValues(value)
    }
    
    @objc func handleSharePost() {
        
        guard
            let caption = captionTextView.text,
            let postImage = photoImageView.image,
            let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.shareButton.isEnabled = false
        shareButton.backgroundColor = #colorLiteral(red: 0.5843137255, green: 0.8, blue: 0.9568627451, alpha: 1)
        
        // image upload data
        guard let uploadData = postImage.jpegData(compressionQuality: 0.8) else { return }
        
        // creation date
        let creationDate = Int(NSDate().timeIntervalSince1970)
        
        // update storage
        let fileName = UUID().uuidString
        STORAGE_POSTS_IMAGES_RES.child(fileName).putData(uploadData, metadata: nil) { (metadata, error) in
            
            //handle error
            if let error = error {
                print("Failed to upload image to storage with error: \(error.localizedDescription)")
                return
            }
            STORAGE_POSTS_IMAGES_RES.child(fileName).downloadURL(completion: { (url, error) in
                
                //handle error
                if let error = error {
                    print("Failed to get image download url with error: \(error.localizedDescription)")
                    return
                }
                
                guard let imageUrl = url?.absoluteString else { return }
                
                // post data
                let values = ["caption": caption,
                              "creationDate": creationDate,
                              "likes": 0,
                              "imageUrl": imageUrl,
                              "ownerUid": currentUid] as [String: Any]
                
                // upload post to database
                let postId = POSTS_REF.childByAutoId()
                guard let postKey = postId.key else { return }
                postId.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    
                    //handle error
                    if let error = error {
                        print("Failed to upload post to database with error: \(error.localizedDescription)")
                        return
                    }
                    // update user-posts structure
                    USER_POSTS_REF.child(currentUid).updateChildValues([postKey: 1])
                    
                    // update user-feeds structure
                    self.updateUserFeeds(with: postKey)
                    
                    // return to home feed
                    self.dismiss(animated: true, completion: {
                        self.tabBarController?.selectedIndex = 0
                    })
                    
                })
                
            })

        }
        
        
    }
    
    
}
