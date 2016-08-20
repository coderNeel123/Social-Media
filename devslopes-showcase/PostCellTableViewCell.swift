//
//  PostCellTableViewCell.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/13/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import UIKit
import Alamofire
import Firebase
import Foundation

class PostCellTableViewCell: UITableViewCell, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var likesImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: MaterialButton!
    
    var post: Post!
    var request: Request!
    var likeRef: Firebase!
    var currentlyEditiing = false
    var imageController: UIImagePickerController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 2.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCellTableViewCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likesImage.addGestureRecognizer(tap)
        likesImage.userInteractionEnabled = true
        
        
        
        


    }

    override func drawRect(rect: CGRect) {
         profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
         profileImage.clipsToBounds = true
         clip2Bounds(profileImage)
         clip2Bounds(showcaseImage)
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func clip2Bounds(image: UIImageView) {
        image.clipsToBounds = true
    }
    
    func configurePost (post: Post, image: UIImage?) {
        let url = NSURL(string: post.postProfileLink!)
        let urlStringChecker = String(url!)
        
        if urlStringChecker != "" {
            if urlStringChecker != "hi" {
                if urlStringChecker != " " {
                    let data = NSData(contentsOfURL: url!)
                    self.profileImage.image = UIImage(data: data!)
                }
                else {
                    self.profileImage.image = UIImage(named: "camera")
                }
                
            }
            else {
                self.profileImage.image = UIImage(named: "camera")
            }
            
        }
        else {
            self.profileImage.image = UIImage(named: "camera")
        }
        

        self.post = post
        self.descriptionField.text = post.postDescription
        self.likesLabel.text = "\(post.postLikes)"
        self.usernameLabel.text = post.postUsername
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)
        if post.postImageUrl != nil {
            if image != nil {
                showcaseImage.image = image
            } else {
                request = Alamofire.request(.GET, post.postImageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { (request, response, data, error) in
                    if error == nil {
                        let image = UIImage(data: data!)!
                        self.showcaseImage.image = image
                        FeedVC.imageCache.setObject(image, forKey: self.post.postImageUrl!)
                    }
                })
            }
        } else {
            self.showcaseImage.hidden = true
        }
        
        
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.likesImage.image = UIImage(named: "heart-empty")
            } else {
                self.likesImage.image = UIImage(named: "heart-full")
            }
        })
    }
   
    @IBAction func deleteButtonPressed(sender: UIButton) {
        
        let userPost = userPosts[sender.tag]
        let firebasePost = DataService.ds.REF_Posts.childByAppendingPath(userPost)
        firebasePost.removeValue()

        userPosts.removeAll()
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        
        likeRef.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if (snapshot.value as? NSNull) != nil {
                self.likesImage.image = UIImage(named: "heart-full")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
            } else {
                self.likesImage.image = UIImage(named: "heart-empty")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
            }
        })
    }
    

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        showcaseImage.image = image
    }
    
    func checkForPosts (post: Post) {
        if currentUid == post.postUid {
            userOwnsPost = true
            DataService.ds.buttonTagValue = DataService.ds.buttonTagValue + 1
            deleteButton.tag = DataService.ds.buttonTagValue
            editButton.tag = DataService.ds.buttonTagValue
            editButton.hidden = false
            deleteButton.hidden = false
            likesImage.hidden = true
            userPosts.append(post.postKey)
        }
        else {
            userOwnsPost = false
            deleteButton.hidden = true
            editButton.hidden = true
            likesImage.hidden = false
        }
    }

}
