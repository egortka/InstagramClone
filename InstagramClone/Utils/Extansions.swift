//
//  Extansions.swift
//  InstagramClone
//
//  Created by Egor Tkachenko on 12/03/2019.
//  Copyright © 2019 ET. All rights reserved.
//

import UIKit

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

var imageCache = [String: UIImage]()

extension UIImageView {
    
    func loadImage(with urlString: String) {
        
        // check if image exist in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
        
        // if image does not exist
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
        
            // handle error
            if let error = error {
                print("Failed to load image from url: ", error.localizedDescription)
                return
            }
            
            // handle image data
            guard let imageData = data else { return }
        
            // set image to cache
            let loadedImage = UIImage(data: imageData)
            imageCache[urlString] = loadedImage
            
            // set image to image view
            DispatchQueue.main.async {
                self.image = loadedImage
            }
        }.resume()
        
    }
}
