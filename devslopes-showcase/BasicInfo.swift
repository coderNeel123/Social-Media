//
//  BasicInfo.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/16/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class BasicInfo: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var buttonLabel: UIButton!
    @IBOutlet weak var basicInfoLabel: UILabel!
    
    var imageSelected = false
    var imagePicker: UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        usernameField.delegate = self
        buttonLabel.setTitle("Next", forState: UIControlState.Normal)
        emailField.hidden = true
        emailField.delegate = self
        
        let size = CGRectMake(0, 0, view.frame.width, 60)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.frame = size
        
        if settingButtonPressed == true {
            emailField.hidden = false
            basicInfoLabel.layoutMargins.top = 84
            if DataService.ds.currentUserPhoto != nil {
            if let url = NSURL(string: DataService.ds.currentUserPhoto) where url != "" {
                let urlStringChecker = String(url)
                if urlStringChecker != "" {
                    if urlStringChecker != "hi" {
                        if urlStringChecker != " " {
                            let data = NSData(contentsOfURL: url)
                            self.profilePhoto.image = UIImage(data: data!)
                        }
                        else {
                            self.profilePhoto.image = UIImage(named: "camera")
                        }
                        
                    }
                    else {
                        self.profilePhoto.image = UIImage(named: "camera")
                    }
                    
                }
                else {
                    self.profilePhoto.image = UIImage(named: "camera")
                }
            }
            }
            else {
                profilePhoto.image = UIImage(named: "camera")
            }
            profilePhoto.clipsToBounds = true
            buttonLabel.setTitle("Update", forState: UIControlState.Normal)
            usernameField.text = DataService.ds.currentUsername
            emailField.text = DataService.ds.currentEmail
            }
        }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        profilePhoto.image = image
        imageSelected = true
        profilePhoto.clipsToBounds = true
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonClicked(sender: AnyObject) {
        
        if let username = usernameField.text where username != "" {
            currentUsername = username
            if let email = emailField.text where email != "" {
                currentEmail = email
            }
            DataService.ds.currentUsername = username
            if let image = profilePhoto.image where imageSelected == true {
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
                                        DataService.ds.updatedUserPhoto = imageLink
                                        DataService.ds.currentUserPhoto = imageLink
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
            }
        }

        performSegueWithIdentifier("basicInfoCompleted", sender: nil)
    }
    
    func postToFirebase (url: String?) {
        var post: Dictionary<String, AnyObject> = [
            "username": usernameField.text!
        ]
        
        if settingButtonPressed {
            post["email"] = emailField.text!
        }
        else {
            post["email"] = currentEmail
        }
        if url != nil {
            post["imageUrl"] = url!
        }
        else {
            post["imageUrl"] = DataService.ds.updatedUserPhoto
        }
        
        
        let firebasePost = DataService.ds.REF_USER_CURRENT_INFORMATION
        firebasePost.removeValue()
        firebasePost.setValue(post)
        
        
        imageSelected = false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}