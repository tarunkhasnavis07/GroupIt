//
//  NewPostViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/21/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse

class NewPostViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var textbox: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    var currUserObject: PFObject!
    let user = PFUser.currentUser()
    var profPicFile: PFFile!

    @IBOutlet weak var classTitle: UITextField!
    
    
    @IBAction func classFieldAction(sender: AnyObject) {
        
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        textbox!.delegate = self
        textbox.text = "Share your thoughts here"
        
        textbox.textColor = UIColor.lightGrayColor()
        textbox.layer.borderWidth = 1
        textbox.layer.borderColor = UIColor.blackColor().CGColor
        //textbox.scrollsToTop = true
        self.automaticallyAdjustsScrollViewInsets = false
        classTitle.placeholder = "Class name here"
        classTitle.textColor = UIColor.grayColor()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func textViewDidBeginEditing(textView: UITextView){
        if (textView.text == "Share your thoughts here"){
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        textView.becomeFirstResponder()
    }
    func textViewDidEndEditing(textView: UITextView) {
        if (textView.text == "") {
            textView.text = "Share your thoughts here"
            textView.textColor = UIColor.lightGrayColor()
        }
        textView.resignFirstResponder()
    }
    func dismissKeyboard(){
        textbox.resignFirstResponder()
    }
    
    
    
//    func textViewDidBeginEditing(textView: UITextView) {
//        if textbox.text == "Share your thoughts here" {
//            textbox.text = ""
//            textbox.textColor = UIColor.blackColor()
//        }
//        textbox.becomeFirstResponder()
//    
//    }
//    
//  
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        
//        if textbox.text == "" {
//            textbox.text = "Share your thoughts here"
//            textbox.textColor = UIColor.lightGrayColor()
//        }
//        else {
//            textbox.textColor = UIColor.blackColor()
//        }
//        
//        textbox.resignFirstResponder()
//    }
    
    func getUser() {
        print("getttttting user")
        let query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo:(user?.objectId)!)
        do {
            let objects = try query.findObjects()
            
            print("error isn't nil")
            // The find succeeded.
            //print("Successfully retrieved \(objects!.count) users.")
            // Do something with the found objects
            if let objects = objects as? [PFObject] {
                for object in objects {
                    print("username is ", object["username"])
                    //cell.username.text = object["username"] as! String
                    self.profPicFile = object["profilePicture"] as! PFFile
                    //                profPicFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    //                    if error == nil {
                    //                        var image1 = UIImage(data:imageData!)
                    //                        cell.profPic.image = image1
                    //                    } else {
                    //                        print(error)
                    
                }
            }
        } catch {
            print(exception)
        }
        
//            //(objects: [PFObject]?, error: NSError?) -> Void in
//        print("finding objects in background")
//        if error == nil {
//            print("error isn't nil")
//            // The find succeeded.
//            //print("Successfully retrieved \(objects!.count) users.")
//            // Do something with the found objects
//            if let objects = objects! as? [PFObject] {
//                for object in objects {
//                    print("username is ", object["username"])
//                //cell.username.text = object["username"] as! String
//                    self.profPicFile = object["profilePicture"] as! PFFile
////                profPicFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
////                    if error == nil {
////                        var image1 = UIImage(data:imageData!)
////                        cell.profPic.image = image1
////                    } else {
////                        print(error)
//                    
//            }
//        } else {
//            print(error)
//            
//            }
        
        //print("COUNT", objects.count)
        //self.postObjects = objects
        //print(self.postObjects)
        
        //for postObject in self.postObjects {
        //self.nameToUserDict[userObject["username"] as! String] = postObject
        //}
        //self.membersTableView.reloadData()
        
        //self.tableView.reloadData()
        
        
        //                    }
        //                } else {
        //                    // Log details of the failure
        //                    print("Error: \(error!) \(error!.userInfo)")
        //                }
        //}
        
        //            object["profilePicture"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
        //                if error == nil {
        //
        //                    cell.cellProfilePic.image = nil
        //
        //                    cell.cellProfilePic.image = UIImage(data:imageData!)
        //                    cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
        //                    cell.cellProfilePic.clipsToBounds = true
        //
        //
        //
        //
        //                } else {
        //                    print(error)
        //                }
        //            }
        //
        //cell.postMainText.text = object["message"] as! String
       // }
        
    }

    
    @IBAction func checkButtonPressed(sender: AnyObject) {
        print("BUTTON PRESSED")
        if self.textbox.text != "" && classTitle.text != "" {
            
            getUser()
            print("got user ")
            var postObject = PFObject(className: "Forum")
            postObject["poster"] = user!.username
            //postObject["poster"] = self.user!.objectId
            postObject["message"] = self.textbox.text
            postObject["profilePic"] = self.profPicFile //save profile picture somehow??
            postObject["classTitle"] = classTitle.text
            postObject.saveInBackgroundWithTarget(nil, selector: nil)
            
//            var query = PFQuery(className:"Forum")
//            //query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
//            query.findObjectsInBackgroundWithBlock {
//                (objects: [PFObject]?, error: NSError?) -> Void in
//                
//                if error == nil {
//                    // The find succeeded.
//                    print("Successfully retrieved \(objects!.count) scores.")
//                    // Do something with the found objects
//                    if let objects = objects {
//                        for object in objects {
//                            object["poster"] = self.currUserObject.objectId
//                            object["message"] = self.textbox.text
//                            object.saveInBackgroundWithTarget(nil, selector: nil)
//                            //self.classes = updatedClasses
//                            //self.saveButton.alpha = 0
//                            //self.HUD.dismiss()
//                        }
//                    }
//                } else {
//                    // Log details of the failure
//                    print("Error: \(error!) \(error!.userInfo)")
//                }
//            }
            
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
