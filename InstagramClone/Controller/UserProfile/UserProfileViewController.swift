//
//  UserProfileViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 13/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "Cell"
private let headerIdentifier = "UserProfileHeader"

class UserProfileViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    // MARK: - Properties
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(UserProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: headerIdentifier)

        // Background color
        self.collectionView.backgroundColor = .white
        
        // fetch user data
        fetchCurrentUserData()
    }


    // MARK: - UICollectionView

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // configure header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! UserProfileHeader
        if let user = self.user {
            header.user = user
        } else {
            print("User was not set")
        }
        
        return header
    }
    
    // MARK: - API
    
    func fetchCurrentUserData() {
        
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(currentUid).observeSingleEvent(of: .value) { (snapShot) in
            guard let userDictionary = snapShot.value as? Dictionary<String, AnyObject> else { return }
            
            let uid = snapShot.key
            let user = User(uid: uid, dictionart: userDictionary)
            
            self.navigationItem.title = user.userName
            self.user = user
            self.collectionView.reloadData()
            
        }
    }
}
