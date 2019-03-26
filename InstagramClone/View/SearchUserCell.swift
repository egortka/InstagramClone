//
//  SearchUserCell.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 15/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {
    
    // MARK: - Properties
    
    var user: User? {
        didSet {
            
            guard let userProgileImageUrl = user?.profileImageUrl else { return }
            guard let username = user?.username else { return }
            guard let fullname = user?.name else { return }
            
            profileImageView.loadImage(with: userProgileImageUrl)
            self.textLabel?.text = username
            self.detailTextLabel?.text = fullname
            
        }
    }

    let profileImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
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
