//
//  UserPostCell.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 22/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

class UserPostCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var post: Post? {
        
        didSet{
            guard let imageUrl = post?.imageUrl else { return }
            photoImageView.loadImage(with: imageUrl)
        }
        
    }
    
    let photoImageView: CustomImageView = {
        let imageView = CustomImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(photoImageView)
        photoImageView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
