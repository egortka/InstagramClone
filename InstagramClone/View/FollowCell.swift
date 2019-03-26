//
//  FollowCell.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 19/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit
import Firebase

class FollowCell: UITableViewCell {
    
    // MARK: - Properties
    
    var delegate: FollowCellDelegate?
    
    var user: User? {
        didSet {
            
            guard let userProgileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profileImageView.loadImage(with: userProgileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname

            // hide button for current user
            if user?.uid == Auth.auth().currentUser?.uid {
                self.followButton.isHidden = true
            }
            
            user?.checkIsUserFollowed(complition: { (followed) in
                
                if followed {

                    self.configureFollowingButton()
                    
                } else {
                    
                    self.configureFollowButton()
                    
                }
            })
            
        }
    }
    
    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    lazy var followButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.06666666667, green: 0.6039215686, blue: 0.9294117647, alpha: 1)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleFollowTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Handlers
    
    @objc func handleFollowTapped() {
        self.delegate?.handleFollowTapped(for: self)
    }
    
    // MARK: - Utils
    
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
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        //add profile image view
        self.addSubview(profileImageView)
        profileImageView.anchor(top: nil, left: leftAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 48, height: 48)
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.layer.cornerRadius = 48 / 2
        
        //add profile name and username
        self.textLabel?.text = "Username"
        self.textLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        
        self.detailTextLabel?.text = "Full Name"
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
        self.detailTextLabel?.textColor = .lightGray
        
        //add follow button
        self.addSubview(followButton)
        followButton.anchor(top: nil, left: nil, bottom: nil, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 12, width: 90, height: 30)
        followButton.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.textLabel?.frame.origin.x = 68
        self.detailTextLabel?.frame.origin.x = 68
        self.textLabel?.frame.origin.y -= 2
    }
} 
