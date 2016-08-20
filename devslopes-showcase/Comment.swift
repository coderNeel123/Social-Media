//
//  Comment.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/17/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

class Comment {
    private var _postComment: String!
    
    
    var postComment: String! {
        return _postComment
    }
    
    private var _postUsername: String!
    
    var postUsername: String! {
        return _postUsername
    }
    
    private var _postUsernamePhoto: String!
    
    var postUsernamePhoto: String! {
        return _postUsernamePhoto
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        if let description = dictionary["commentDescription"] as? String {
            self._postComment = description
        }
        if let username = dictionary["username"] as? String {
            self._postUsername = username
        }
        if let usernamePhoto = dictionary["usernamePhoto"] as? String {
            self._postUsernamePhoto = usernamePhoto
        }

    }
}