//
//  PostUpdate Controller.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/19/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class PostUpdate_Controller: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var descriptionField: MaterialTextField!
    
    var imageSelected = false
    var imageController: UIImagePickerController!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        descriptionField.delegate = self
        
        postPhoto.clipsToBounds = true
        
        let size = CGRectMake(0, 0, view.frame.width, 60)
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController?.navigationBar.frame = size
        
        
        imageController = UIImagePickerController()
        imageController.delegate = self
        print(value1)
        print(value2)
        if DataService.ds.updatedPostPhoto != "" {
            let url = NSURL(string: value1)
            let data = NSData(contentsOfURL: url!)
            postPhoto.image = UIImage(data: data!)
        }
        
        
        if DataService.ds.upadatedPostDescripiotn != "" {
            descriptionField.text = value2
        }

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(PostUpdate_Controller.setValues(_:)), name: "post", object: nil)
    }
    
    @IBAction func postPhotoClicked(sender: AnyObject) {
        presentViewController(imageController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        imageController.dismissViewControllerAnimated(true, completion: nil)
        postPhoto.image = image
        imageSelected = true
        postPhoto.clipsToBounds = true 
    }
    
    @IBAction func updatedPostButton(sender: AnyObject) {
        if descriptionField.text != "" {
            if let image = postPhoto.image where imageSelected == true {
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
    }
    
    func postToFirebase (url: String?) {
        print(DataService.ds.currentEditingPost)
        var post: Dictionary<String, AnyObject> = [
            "description": descriptionField.text!,
            "username": DataService.ds.currentUsername,
            "email": DataService.ds.currentEmail,
            "usernamePhoto": DataService.ds.currentUserPhoto
        ]
        
        if url != nil {
            post["imageUrl"] = url!
        }
        
        
        let firebasePost = DataService.ds.REF_Posts.childByAppendingPath(DataService.ds.currentEditingPost)
        firebasePost.updateChildValues(post)
        
        
        imageSelected = false
        performSegueWithIdentifier("updatedPostCompleted", sender: nil)
    }

    func setValues (notif: AnyObject) {
        if DataService.ds.updatedPostPhoto != "" {
            let url = NSURL(string: value1)
            let data = NSData(contentsOfURL: url!)
            postPhoto.image = UIImage(data: data!)
        }
        
        
        if DataService.ds.upadatedPostDescripiotn != "" {
            descriptionField.text = value2
        }

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
