//
//  DataService.swift
//  devslopes-showcase
//
//  Created by Mark Price on 8/24/15.
//  Copyright © 2015 devslopes. All rights reserved.
//


import Firebase

class DataService {
    
    static let ds = DataService()
    
    var currentEditingPost = ""
    
    var updatedPostPhoto = ""
    
    var upadatedPostDescripiotn = ""
    
    var buttonTagValue = -1
    
    var currentUsername: String!
    
    var currentUserPhoto: String!
    
    var updatedUserPhoto: String!
    
    var currentEmail: String!
    
    private var _REF_BASE = Firebase(url: "\(baseUrl)")
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    private var _REF_Posts = Firebase(url: "\(baseUrl)/posts")
    
    var REF_Posts: Firebase {
        return _REF_Posts
    }
    
    private var _REF_Users = Firebase(url: "\(baseUrl)/users")
    
    var REF_Users: Firebase {
        return _REF_Users
    }
    
    func createFirebaseUser (uid: String, user: Dictionary<String, String>) {
        REF_Users.childByAppendingPath(uid).setValue(user)
    }
    
    var REF_USER_CURRENT: Firebase {
        var uid = ""
        if currentUid == "" {
             uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        }
        else {
            uid = currentUid
        }
        let user = Firebase(url: "\(baseUrl)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    var CURRENT_UID = currentUid
    var REF_POST_CLICKED: Firebase {
        let user = Firebase(url: "\(baseUrl)").childByAppendingPath("posts").childByAppendingPath(currentPostKeyClicked)
        return user!
    }
    
    var REF_USER_CURRENT_INFORMATION: Firebase {
        var uid = ""
        if currentUid == "" {
            uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        }
        else {
            uid = currentUid
        }
        let user = Firebase(url: "\(baseUrl)").childByAppendingPath("users").childByAppendingPath(uid).childByAppendingPath("information")
        return user!
    }
    
}