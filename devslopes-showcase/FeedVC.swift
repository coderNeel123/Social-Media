  //
//  FeedVC.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/13/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textInputField: MaterialTextField!
    @IBOutlet weak var cameraTap: UIImageView!
    @IBOutlet weak var stackView: MaterialView!
    
    var posts = [Post]()
    var imageSelected = false
    static var imageCache = NSCache()
    
    var imagePicker: UIImagePickerController!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        DataService.ds.updatedPostPhoto = ""
        DataService.ds.upadatedPostDescripiotn = ""
            stackView.hidden = false
            tableView.delegate = self
            tableView.dataSource = self
        
        let size = CGRectMake(0, 0, view.frame.width, 60)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.frame = size
        
            textInputField.delegate = self
        
        
            tableView.estimatedRowHeight = 400
        
            imagePicker = UIImagePickerController()
            imagePicker.delegate = self
        
        
        DataService.ds.REF_USER_CURRENT.observeEventType(.Value, withBlock: {snapshot in
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]  {
                for snap in snapshots {
                    if let userDictionary = snap.value as? Dictionary<String, AnyObject> {
                        
                        if let currentPhoto = userDictionary["imageUrl"] as? String {
                            DataService.ds.currentUserPhoto = currentPhoto
                        }
                        
                        if let username = userDictionary["username"] as? String {
                            DataService.ds.currentUsername = username
                        }
                        
                        if let email = userDictionary["email"] as? String {
                            DataService.ds.currentEmail = email
                        }
                            
                        else {
                            if let username = userDictionary["email"] as? String {
                                DataService.ds.currentUsername = username
                            }
                        }
                    }
                    else {
                        currentUsername = "Anonymous"
                        currentUserPhoto = ""
                        currentInfo = nil
                    }
                }
            }
        })
        
        
            DataService.ds.REF_Posts.observeEventType(.Value, withBlock: {snapshot in
             self.posts = []
                DataService.ds.buttonTagValue = -1
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]  {
                    for snap in snapshots.reverse() {
                        if let postDictionary = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let post = Post(postKey: key, dictionary: postDictionary)
                            self.posts.append(post)
                            userPosts.removeAll()
                            postKeys.append(post.postKey)
                        }
                    }
                }
                self.tableView.reloadData()
        })
        
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let currentPost = posts[indexPath.row]
        currentPostKeyClicked = currentPost.postKey
        performSegueWithIdentifier("comments", sender: nil)
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]

        if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCellTableViewCell {
            var image: UIImage?
            cell.request?.cancel()
            if let url = post.postImageUrl {
                image = FeedVC.imageCache.objectForKey(url) as? UIImage
            }
            cell.configurePost(post, image: image)
            cell.checkForPosts(post)
            return cell
        }
        else {
            return PostCellTableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let post = posts[indexPath.row]
        if post.postImageUrl == nil {
            if userOwnsPost {
            return 200
            }
            else {
                return 150
            }
        }
        else {
            if userOwnsPost {
            return tableView.estimatedRowHeight
            }
            else {
                return 358
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        cameraTap.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func makePost(sender: AnyObject) {
        if let text = textInputField.text where text != "" {
            if let image = cameraTap.image where imageSelected == true {
                let urlString = "https://post.imageshack.us/upload_api.php"
                let url = NSURL(string: urlString)!
                let imageData = UIImageJPEGRepresentation(image, 0.2)!
                let apiKey = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
                let keyJson = "json".dataUsingEncoding(NSUTF8StringEncoding)!
                
                
                Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
                    multipartFormData.appendBodyPart(data: imageData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                    multipartFormData.appendBodyPart(data: apiKey, name: "key")
                    multipartFormData.appendBodyPart(data: keyJson, name: "format")
                }) { encodingResult in
                    switch(encodingResult) {
                    case .Success(let upload, _,_):
                        upload.responseJSON(completionHandler: {request, response, result in
                            if let info = result.value as? Dictionary<String,AnyObject> {
                                if let links = info["links"] as? Dictionary<String, AnyObject> {
                                    if let imageLink = links["image_link"] as? String {
                                        self.postToFirebase(imageLink)
                                        self.savePost()
                                    }
                                }
                            }
                        })
                    case .Failure(let error):
                        print(error)
                    }
                }
            }
            else {
                self.postToFirebase(nil)
                savePost()
            }
        }
    }
    
    func savePost () {
        var post: Dictionary<String, AnyObject> = [
            :]
        let firebasePost = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAutoId()
            post["postUid"] = currentPostKey
        firebasePost.setValue(post)
    }
    
    func postToFirebase (url: String?) {
        var post: Dictionary<String, AnyObject> = [
            "description": textInputField.text!,
            "likes": 0,
            "userUid": currentUid,
            "email": DataService.ds.currentEmail
        ]
        
        if url != nil {
            post["imageUrl"] = url!
        }
        if DataService.ds.currentUserPhoto == nil {
            post["usernamePhoto"] = currentUserPhoto
        }
        else {
            post["usernamePhoto"] = DataService.ds.currentUserPhoto
        }
        
        if DataService.ds.currentUsername == nil {
            post["username"] = currentEmail
        }
        else {
            post["username"] = DataService.ds.currentUsername
        }
        
        let firebasePost = DataService.ds.REF_Posts.childByAutoId()
        currentPostKey = firebasePost.key
        post["postKey"] = firebasePost.key
        firebasePost.setValue(post)
        
        textInputField.text = ""
        cameraTap.image = UIImage(named: "camera")
        tableView.reloadData()
        imageSelected = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    
    @IBAction func settingsPressed(sender: AnyObject) {
        settingButtonPressed = true
    }
    
    @IBAction func logOut(sender: AnyObject) {
        DataService.ds.REF_BASE.unauth()
        performSegueWithIdentifier("logOut", sender: nil)
    }
    
    func switchControllers () {
        performSegueWithIdentifier("updatePost", sender: nil)
    }
    
    
    @IBAction func editButtonPressed(sender: UIButton) {
        let userPost = userPosts[sender.tag]
        print("USER POST: \(userPost)")
        DataService.ds.currentEditingPost = userPost
        let link = DataService.ds.REF_Posts.childByAppendingPath(userPost)
        print("USER LINK: \(link)")
        link.observeSingleEventOfType(.Value, withBlock: {snapshot in
            if let userDictionary = snapshot.value as? Dictionary<String, AnyObject> {
                if let currentPhoto = userDictionary["imageUrl"] as? String {
                    DataService.ds.updatedPostPhoto = currentPhoto
                    value1 = currentPhoto
                }
                else {
                    DataService.ds.updatedPostPhoto = ""
                }
                
                if let currentDescription = userDictionary["description"] as? String {
                    DataService.ds.upadatedPostDescripiotn = currentDescription
                    value2 = currentDescription
                }
                
            }
            NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "post", object: nil))

            print("USER PHOTO: \(DataService.ds.updatedPostPhoto)")
            print("USER DESCRIPTION: \(DataService.ds.upadatedPostDescripiotn)")
        })
        link.removeAllObservers()
        switchControllers()
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "post", object: nil))

        
    }
    
}
