//
//  CommentViewController.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 30/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

private let reuseIdentifier = "CommentCell"

class CommentViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    
    var postId: String?
    var comments = [Comment]()
    
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 5, width: 100, height: 50)
        containerView.backgroundColor = .white
        
        containerView.addSubview(postButton)
        postButton.anchor(top: nil, left: nil, bottom: nil, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 50, height: 0)
        postButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        
        containerView.addSubview(commentTextField)
        commentTextField.anchor(top: containerView.topAnchor, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 12, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let seporatorView = UIView()
        seporatorView.backgroundColor = #colorLiteral(red: 0.9019607843, green: 0.9019607843, blue: 0.9019607843, alpha: 1)
        containerView.addSubview(seporatorView)
        seporatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: commentTextField.topAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return containerView
    }()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter comment"
        textField.font = UIFont.systemFont(ofSize: 14)
        return textField
    }()
    
    lazy var postButton: UIButton = {
        let button = UIButton()
        button.setTitle("Post", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(handleUploadPost), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cell
        collectionView.register(CommentCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        
        // configure collection view
        collectionView.backgroundColor = .white
        collectionView.alwaysBounceVertical = true
        collectionView.keyboardDismissMode = .interactive
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        collectionView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: -50, right: 0)
        
        // set title
        navigationItem.title = "Comments"
        
        // fetch comments
        fetchComments()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - CollectionView
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        let dummyCell = CommentCell(frame: frame)
        dummyCell.comment = comments[indexPath.item]
        dummyCell.layoutIfNeeded()
        
        let targetSize = CGSize(width: collectionView.frame.width, height: 1000)
        let estimatedSize = dummyCell.systemLayoutSizeFitting(targetSize)
        
        let height = max(60, estimatedSize.height)
        return CGSize(width: view.frame.width, height: height)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CommentCell
        cell.comment = comments[indexPath.item]
        return cell
    }
    
    // MARK: - Handlers
    
    @objc func handleUploadPost() {
        
        
        guard commentTextField.hasText else { return }
        guard let postId = self.postId else { return }
        guard let commentText = commentTextField.text else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let creationDate = Double(NSDate().timeIntervalSince1970)
        
        postButton.isEnabled = false
        
        let values = ["commentText": commentText,
                      "creationDate": creationDate,
                      "uid": uid] as [String : Any]
        
        COMMENTS_REF.child(postId).childByAutoId().updateChildValues(values) { (err, ref) in
            self.commentTextField.text = nil
            self.postButton.isEnabled = true
        }
    }
    
    func fetchComments() {
        
        guard let postId = self.postId else { return }
        
        COMMENTS_REF.child(postId).observe(.childAdded) { (snapshot) in
            
            guard let dict = snapshot.value as? Dictionary<String, AnyObject> else { return }
            guard let uid = dict["uid"] as? String else { return }
            
            Database.fetchUser(with: uid, complition: { (user) in
                
                let comment = Comment(with: user, dictionary: dict)
                self.comments.append(comment)
                
                self.collectionView.reloadData()
            })
        }
        
    }
}
