//
//  CommentController.swift
//  devslopes-showcase
//
//  Created by Neel Khattri on 8/17/16.
//  Copyright © 2016 devslopes. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class CommentController: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var commentField: MaterialTextField!
    @IBOutlet weak var tableView: UITableView!

    var comments = [Comment]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentField.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        let size = CGRectMake(0, 0, view.frame.width, 60)

         self.navigationController?.navigationBarHidden = false
         self.navigationController?.navigationBar.frame = size
        
        DataService.ds.REF_POST_CLICKED.childByAppendingPath("comment").observeEventType(.Value, withBlock: {snapshot in
            self.comments = []
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot]  {
                for snap in snapshots {
                    if let commentDictionary = snap.value as? Dictionary<String, AnyObject> {
                        let comment = Comment(dictionary: commentDictionary)
                        self.comments.append(comment)
                    }
                }
            }
            self.tableView.reloadData()
        })
        
    }

    @IBAction func commentButtonClicked(sender: AnyObject) {
        if commentField.text != nil {
        postToFirebase()
        }
    }

    func postToFirebase () {
        let comment: Dictionary<String, AnyObject> = [
            "commentDescription": commentField.text!,
            "usernamePhoto": DataService.ds.currentUserPhoto,
            "username": DataService.ds.currentUsername
        ]
        
        
        let firebasePost = DataService.ds.REF_POST_CLICKED.childByAppendingPath("comment").childByAutoId()
        firebasePost.setValue(comment)
        
        commentField.text = ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentPosted") as? CommentsPosted {
            cell.configureComment(comment)
            return cell
        }
        else {
            return CommentsPosted()
        }

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 130
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
}
