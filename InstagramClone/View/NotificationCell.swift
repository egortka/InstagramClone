//
//  NotificationCell.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 11/04/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    // MARK: - Properties
    
    var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        
        didSet {
            
            guard let profileImage = notification?.user.profileImageUrl else { return }
            profileImageView.loadImage(with: profileImage)
            
            configureNotificationLabel()
            
            configureNotificationType()
            
            if let postImageUrl = notification?.post?.imageUrl {
                postImageView.loadImage(with: postImageUrl)
            }
        }
        
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var postImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        
        let postTap = UITapGestureRecognizer(target: self, action: #selector(handlePostTapped))
        postTap.numberOfTapsRequired = 1
        imageView.addGestureRecognizer(postTap)
        imageView.isUserInteractionEnabled = true
        
        return imageView
    }()
    
    let notificationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.6039215686, blue: 0.9294117647, alpha: 1)
        button.layer.cornerRadius = 3
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        //add profile image
        self.addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, bottom: nil, right: nil, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 40, height: 40)
        profileImageView.layer.cornerRadius = 40 / 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Handlers
    
    func configureNotificationLabel() {
        
        guard let username = notification?.user.username else { return }
        guard let notificationMesage = notification?.notificationType.description else { return }
        
        let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        attributedText.append(NSAttributedString(string: notificationMesage, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)]))
        attributedText.append(NSAttributedString(string: " 2d", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        
        notificationLabel.attributedText = attributedText
    }
    
    func configureNotificationType() {
        
        guard let notificationType = notification?.notificationType else { return }
        
        var anchor: NSLayoutXAxisAnchor?
        
        if notificationType == .Follow {
            
            //add follow button
            self.addSubview(followButton)
            followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
            followButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            anchor = followButton.leftAnchor
            
            notification?.user.checkIsUserFollowed(complition: { (followed) in
                if followed {
                    self.configureFollowingButton()
                } else {
                    self.configureFollowButton()
                }
            })
            
        } else {
            
            //add post image
            self.addSubview(postImageView)
            postImageView.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 40, height: 40)
            postImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            anchor = postImageView.leftAnchor
        }
        
        if let notificationLabelRightAnchor = anchor {
            
            //add notification label
            self.addSubview(notificationLabel)
            notificationLabel.anchor(top: nil, left: profileImageView.rightAnchor, bottom: nil, right: notificationLabelRightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
            notificationLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        }
    }
    
    func configureFollowingButton() {
        // configure button for followed user
        self.followButton.setTitle("Following", for: .normal)
        self.followButton.setTitleColor(.black, for: .normal)
        self.followButton.layer.borderColor = UIColor.lightGray.cgColor
        self.followButton.layer.borderWidth = 0.5
        self.followButton.backgroundColor = .white
    }
    
    func configureFollowButton() {
        // configure button for non followed user
        self.followButton.setTitle("Follow", for: .normal)
        self.followButton.setTitleColor(.white, for: .normal)
        self.followButton.layer.borderWidth = 0
        self.followButton.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.6039215686, blue: 0.9294117647, alpha: 1)
    }
    
    @objc func handleFollowTapped() {
        delegate?.handleFollowTapped(for: self)
    }
    
    @objc func handlePostTapped() {
        delegate?.handlePostTapped(for: self)
    }
}
