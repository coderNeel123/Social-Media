//
//  Post.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/14/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import Foundation
import Firebase
import UIKit

class Post {
    private var _postDescription: String!
    private var _postImageUrl: String?
    private var _postLikes: Int!
    private var _postUsername: String!
    private var _postKey: String!
    private var _postProfileLink: String?
    private var _currentUserPhoto: String!
    private var _currentUsername: String!
    private var _postReference: Firebase!

    
    var postDescription: String {
        return _postDescription
    }
    
    var postProfileLink: String? {
        return _postProfileLink
    }
    
    var postUid: String!
    
    var postImageUrl: String? {
        return _postImageUrl
    }
    
    var postLikes: Int {
        if _postLikes == nil {
            return 0
        }
        else {
        return _postLikes
        }
    }
    
    var postUsername: String {
        return _postUsername
    }
    
    var postKey: String {
        return _postKey
    }
    
    init(description: String, imageUrl: String?, username: String) {
        self._postDescription = description
        self._postImageUrl = imageUrl
        self._postUsername = username
    }
    
    init(postKey: String, dictionary: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let likes = dictionary["likes"] as? Int {
            self._postLikes = likes
        }
        
        if let imageUrl = dictionary["imageUrl"] as? String {
            self._postImageUrl = imageUrl
        }
        
        if let description = dictionary["description"] as? String {
            self._postDescription = description
        }
        
        if let username = dictionary["username"] as? String {
            self._postUsername = username
        }
 
        if let photo = dictionary["usernamePhoto"] as? String {
            self._postProfileLink = photo
        }
        
        if let uid = dictionary["userUid"] as? String {
            self.postUid = uid
        }
        
        self._postReference = DataService.ds.REF_Posts.childByAppendingPath(self._postKey)
    }
    
    init (dictionary: Dictionary<String, AnyObject>) {
        if let currentPhoto = dictionary["imageUrl"] as? String {
            self._currentUserPhoto = currentPhoto
        }
        
        if let username = dictionary["username"] as? String {
            self._currentUsername = username
        }
        else {
            if let username = dictionary["email"] as? String {
                self._currentUsername = username
            }
        }

    }
    
    
    func adjustLikes (addLike: Bool) {
        if addLike == true {
            _postLikes = _postLikes + 1
        }
        else {
            _postLikes = _postLikes - 1
        }
        
        _postReference.childByAppendingPath("likes").setValue(_postLikes)
    }
}