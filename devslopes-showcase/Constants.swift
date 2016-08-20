//
//  Constants.swift
//  devslopes-showcase
//
//  Created by Mark Price on 8/21/15.
//  Copyright © 2015 devslopes. All rights reserved.
//

import Foundation
import UIKit

let SHADOW_COLOR:CGFloat = 157.0 / 255.0

//Keys
let KEY_UID = "uid"

//Segues
let SEGUE_LOGGED_IN = "loggedIn"

//Status Codes
let STATUS_ACCOUNT_NONEXIST = -8

let baseUrl = "https://pet-lovers.firebaseio.com"

var currentUid = ""

var currentEmail = ""

var currentUsername = ""

var currentUserPhoto = ""

var settingButtonPressed = false

var currentPostKeyClicked = ""

var currentInfo: Post!

var currentPostKey = ""

var postKeys = [String]()

var currentUserUid = ""

var userPosts = [String]()

var userOwnsPost = false

var currentUserPost = ""

var value1 = ""

var value2 = ""