//
//  CommentPosted.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/17/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import Alamofire

class CommentsPosted: UITableViewCell {
    
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }
    
    func configureComment (comment: Comment) {
        self.commentField.text = comment.postComment
        self.usernameLabel.text = comment.postUsername
        if let urlLink = comment.postUsernamePhoto {
            if let url = NSURL(string: urlLink) {
                if let data = NSData(contentsOfURL: url) {
                    profileImage.image = UIImage(data: data)
                }
            }
        }
        
    }
}