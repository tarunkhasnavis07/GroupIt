//
//  MyProfileViewController.swift
//  ParseStarterProject
//
//  Created by Akkshay Khoslaa on 1/11/16. --
//  Copyright © 2016 Parse. All rights reserved.
//

import UIKit
import JGProgressHUD
import ParseFacebookUtilsV4
import STZPopupView
class MyProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    

    var backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 260))
    var blackImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 210))
    var secondBlackImageView = UIImageView(frame: CGRect(x: 0, y: 210, width: UIScreen.mainScreen().bounds.width, height: 50))
    var profPicImageView = UIImageView(frame: CGRect(x: (UIScreen.mainScreen().bounds.width - 130)/2, y: 35, width: 130, height: 130))
    var usernameLabel = UILabel(frame: CGRect(x: 10, y: 170, width: UIScreen.mainScreen().bounds.width - 20, height: 30))
//    var logoutLabel = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 66, y: 222.5, width: 60, height: 25))
    var plusButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 90, y: 20, width: 80, height: 30))
    var saveButton = UIButton(frame: CGRect(x: (UIScreen.mainScreen().bounds.width - 180)/2, y: UIScreen.mainScreen().bounds.height - 50, width: 180, height: 40))
    var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
    var editButton = UIButton(frame: CGRect(x: 6, y: 222.5, width: 50, height: 25))
    var doneButton = UIButton(frame: CGRect(x: UIScreen.mainScreen().bounds.width - 30, y: 205, width: 20, height: 25))
    var activeClassLabel = UILabel(frame: CGRect(x: (UIScreen.mainScreen().bounds.width - 220)/2, y: 220, width: 220, height: 30))
    let popupView = UIView(frame: CGRect(x: 0, y: 200, width: Int(UIScreen.mainScreen().bounds.width), height: Int(3*(((UIScreen.mainScreen().bounds.width/320) * 80) + 50))))
    var showAlert = false
    var currUserObject: PFObject!
    var classes = Array<String>()
    var cells = Array<UITableViewCell>()
    var editButtons = Array<UIButton>()
    var doneButtons = Array<UIButton>()
    var classTextFields = Array<UITextField>()
    var classLabels = Array<UILabel>()
    var activeClassLabels = Array<UILabel>()
    var loaded = false
    var editMode = false
    var activeField:UITextField?
    var lightColor = UIColor.grayColor()
    var darkColor = UIColor.grayColor()
    
    override func viewDidAppear(animated: Bool) {
//        if showAlert == true {
//            showContentAlert()
//        }
    }
    func buttonAction(sender:UIButton!)
    {
        print("Button tapped")
//        let loginManager = FBSDKLoginManager()
//        loginManager.logOut()

        PFUser.logOutInBackgroundWithBlock { (error:NSError?) -> Void in
            
            if(error == nil) {
                
                 self.dismissViewControllerAnimated(true, completion: nil)
            } else {
               
            }
        }
     
        
        //self.window.rootViewController = ViewController(nibName: nil, bundle: nil)
        //self.performSegueWithIdentifier("logoutSegue", sender: self)
    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "logoutSeg" {
//            let destVC = segue.destinationViewController as! ViewController
//            destVC.performedLogout = true
//        }
//    }
//    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        for family: String in UIFont.familyNames()
//        {
//            print("\(family)")
//            for names: String in UIFont.fontNamesForFamilyName(family)
//            {
//                print("== \(names)")
//            }
//        }
        
        activeClassLabel.frame = CGRect(x: editButton.frame.maxX + 10, y: 220, width: 220, height: 30)
        
          var tabBarHeight = UITabBar().frame.height
        saveButton.frame = CGRect(x: (UIScreen.mainScreen().bounds.width - 180)/2, y: UIScreen.mainScreen().bounds.height - 40 - 50 - 10, width: 180, height: 40)


//        var image: UIImage = UIImage(named: "sathe")!
//        self.tableView.backgroundView = nil
//        self.tableView.backgroundColor = UIColor(patternImage: image)

        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        
        let myPurpleColor = colorWithHexString ("#7d0541")
        let myGrayColor = colorWithHexString ("#9ddaf6")
        
//        editButton.setImage(UIImage(named: "edit-1"), forState: .Normal)
        editButton.setTitle("Edit", forState: .Normal)
        editButton.layer.cornerRadius = 5
        editButton.layer.borderColor = UIColor.whiteColor().CGColor
        editButton.layer.borderWidth = 1
        editButton.addTarget(self, action: "editButtonPressed:", forControlEvents: .TouchUpInside)
        editButton.tag = 3
        editButton.titleLabel?.font = UIFont.systemFontOfSize(15)
//        editButton.setTitle("Test Button", forState: UIControlState.Normal)
//        self.view.addSubview(editButton)
        
        activeClassLabel.text = "ACTIVE CLASS: "
        activeClassLabel.font = UIFont.systemFontOfSize(14)
        activeClassLabel.textAlignment = .Center
        activeClassLabel.textColor = UIColor.whiteColor()
//        activeClassLabel.adjustsFontSizeToFitWidth = true
        
        
        saveButton.setTitle("SAVE", forState: .Normal)
        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        saveButton.backgroundColor = Constants.greenColor
        saveButton.addTarget(self, action: "saveClasses", forControlEvents: .TouchUpInside)
        saveButton.layer.cornerRadius = 5
        saveButton.alpha = 0
        self.view.addSubview(saveButton)
        
        
        
        
        self.navigationController?.navigationBar.hidden = true
        beganKeyboardNotifications()
//        
//        var tapToDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
//        tapToDismiss.cancelsTouchesInView = false
//        self.view!.addGestureRecognizer(tapToDismiss)

        
        getCurrUserObject()
//        saveButton.setTitle("SAVE", forState: .Normal)
//        saveButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//        saveButton.backgroundColor = myGrayColor
//        saveButton.addTarget(self, action: "saveClasses", forControlEvents: .TouchUpInside)
//        saveButton.layer.cornerRadius = 5
//        saveButton.alpha = 0
        plusButton.setTitle(" ADD CLASS ", forState: .Normal)
        plusButton.setTitleColor(myGrayColor, forState: .Normal)
        plusButton.titleLabel?.adjustsFontSizeToFitWidth = true
        plusButton.titleLabel!.font = UIFont(name: "System", size: 9)
        plusButton.layer.cornerRadius = 4
        //plusButton.layer.borderColor = UIColor.grayColor().CGColor
        //plusButton.layer.borderWidth = 0.2
        plusButton.hidden = true
        plusButton.alpha = 0
        plusButton.addTarget(self, action: "plusButtonPressed:", forControlEvents: .TouchUpInside)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "profileCell")
        tableView.separatorStyle = .None
        tableView.scrollEnabled = false
        tableView.keyboardDismissMode = .Interactive
        //tableView.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(animated: Bool) {
        endKeyboardNotifications()
    }
    func getCurrUserObject() {
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.currUserObject = objects.first
                        if self.currUserObject["user_courses"] != nil {
                            self.classes = self.currUserObject["user_courses"] as! Array<String>
                            print("curr classes are")
                            print(self.classes)
                        }
                        
                        if self.currUserObject["activeClass"] != nil {
                            self.activeClassLabel.text = "ACTIVE CLASS:" + (object["activeClass"] as! String)
                        }
                        
                        self.loaded = true
                        for label in self.classLabels {
                            label.removeFromSuperview()
                        }
                        
                        for textField in self.classTextFields {
                            textField.removeFromSuperview()
                        }
                        self.cells = Array<UITableViewCell>()
                        self.editButtons = Array<UIButton>()
                        self.doneButtons = Array<UIButton>()
                        self.classTextFields = Array<UITextField>()
                        self.classLabels = Array<UILabel>()
                        self.activeClassLabels = Array<UILabel>()
                        self.tableView.reloadData()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }


    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("classes are")
        print(classes)
        var numSmallRows = (UIScreen.mainScreen().bounds.height - 230)/50
        return Int(numSmallRows) + 1
    }

    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("profileCell") as! UITableViewCell?
        var numSmallRows = (UIScreen.mainScreen().bounds.height - 230)/50
        //cell?.backgroundColor = UIColor.whiteColor()
        cell?.selectionStyle = .None
        print("right now the edit mode is (inside cellfor)")
        print(editMode)
        
        if indexPath.row == 0 {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            if loaded == true {
                var profPicFile = currUserObject["profilePicture"] as! PFFile
                profPicFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        var image1 = UIImage(data:imageData!)
                        self.profPicImageView.image = image1
                    } else {
                        print(error)
                    }
                }
            }
            var blur:UIBlurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            var effectView:UIVisualEffectView = UIVisualEffectView (effect: blur)
            effectView.frame = CGRect(x: 0, y: 210, width: UIScreen.mainScreen().bounds.width, height: 260)
            backgroundImageView.clipsToBounds = true
//            backgroundImageView.addSubview(effectView)
            var yourFont: UIFont = UIFont.systemFontOfSize(23)
            usernameLabel.font = yourFont
//            logoutLabel.setTitle("Logout", forState: .Normal)
//            logoutLabel.setTitleColor(UIColor.whiteColor(), forState: .Normal)
//            logoutLabel.titleLabel!.font = UIFont.systemFontOfSize(15)
//            
//            //logoutLabel.textFfont = yourFont
//            logoutLabel.addTarget(self, action: "buttonAction:", forControlEvents: UIControlEvents.TouchUpInside)
//
//            
            profPicImageView.contentMode = .ScaleAspectFill
            profPicImageView.layer.borderColor = Constants.greenColor.CGColor
            profPicImageView.layer.borderWidth = 2
            profPicImageView.clipsToBounds = true
            profPicImageView.layer.cornerRadius = profPicImageView.bounds.width/2
            backgroundImageView.image = UIImage(named: "campanile")
            blackImageView.image = UIImage(named: "black")
            blackImageView.alpha = 0.4
            secondBlackImageView.image = UIImage(named: "black")
            secondBlackImageView.alpha = 0.4
            backgroundImageView.clipsToBounds = true
            usernameLabel.text = PFUser.currentUser()?.username
           // logoutLabel.text = "Logout"
            //logoutLabel.font = UIFont(name: "System", size: 10)
//            logoutLabel.layer.borderWidth = 1
//            logoutLabel.layer.borderColor = UIColor.whiteColor().CGColor
//            logoutLabel.layer.cornerRadius = 3
            //usernameLabel.font = UIFont(name: "System", size: 18)
            usernameLabel.textColor = UIColor.whiteColor()
            usernameLabel.textAlignment = .Center
            //logoutLabel.titleColorForState(.Normal) = UIColor.whiteColor()
            //logoutLabel = Constants.greenColor
//            logoutLabel.layer.borderColor = Constants.greenColor.CGColor
            //logoutLabel.textAlignment = .Center
            cell!.addSubview(backgroundImageView)
            cell?.addSubview(secondBlackImageView)
            cell!.addSubview(blackImageView)
            cell!.addSubview(profPicImageView)
            cell!.addSubview(usernameLabel)
//            cell!.addSubview(logoutLabel)
            cell?.addSubview(activeClassLabel)
            cell!.bringSubviewToFront(profPicImageView)
            cell!.bringSubviewToFront(usernameLabel)
//            cell!.bringSubviewToFront(logoutLabel)
            cell?.bringSubviewToFront(activeClassLabel)
            
            
//            editButton.setImage(UIImage(named: "edit-1"), forState: .Normal)
//            editButton.addTarget(self, action: "editButtonPressed:", forControlEvents: .TouchUpInside)
            //editButton.tag = indexPath.row - 1
            
            doneButton.setImage(UIImage(named: "checkmark"), forState: .Normal)
            doneButton.addTarget(self, action: "doneButtonPressed:", forControlEvents: .TouchUpInside)
            doneButton.tag = indexPath.row - 1
            doneButton.hidden = true
            doneButton.alpha = 0
            
            cell?.addSubview(doneButton)
            cell?.addSubview(editButton)
            
        } else if indexPath.row <= classes.count && indexPath.row != classes.count + 1 {
            
//            if cells.count < indexPath.row {
                print("right now the edit mode is")
                print(editMode)
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            
            
                var classTextField = UITextField(frame: CGRect(x: 20, y: ((cell?.frame.height)! - 45)/2 , width: UIScreen.mainScreen().bounds.width - 40, height: 45))
                classTextField.font = UIFont(name: (classTextField.font?.fontName)!, size: 17)
                classTextField.layer.cornerRadius = 1
                classTextField.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
                classTextField.borderStyle = .None
                classTextField.text = classes[indexPath.row - 1]
                classTextField.placeholder = "<Your class here>"
                classTextField.textAlignment = .Center
                classTextField.delegate = self
                classTextField.textColor = Constants.greenColor
                
                var classLabel = UILabel(frame: CGRect(x: 40, y: ((cell?.frame.height)! - 45)/2 , width: UIScreen.mainScreen().bounds.width - 80, height: 45))
                classLabel.textAlignment = .Center
                classLabel.text = classes[indexPath.row - 1]
                classLabel.font = classLabel.font.fontWithSize(17)
                classLabel.textColor = Constants.greenColor
                
            
                
                let myBlueColor = colorWithHexString ("#9ddaf6")
                
                //activeClassLabel.textColor = Constants.greenColor
//                activeClassLabel.adjustsFontSizeToFitWidth = true
//                if (currUserObject["activeClass"] as! String) != classLabel.text {
//                    activeClassLabel.alpha = 0
//                    activeClassLabel.hidden = true
//                }
            
                if editMode == true {
                    classTextField.hidden = false
                    classTextField.alpha = 1
                    classLabel.hidden = true
                    classLabel.alpha = 0
                    print("got into edit place")
                } else {
                    classTextField.hidden = true
                    classTextField.alpha = 0
                    classLabel.hidden = false
                    classLabel.alpha = 1
                }
                
//                activeClassLabels.append(activeClassLabel)
                classLabels.append(classLabel)
                classTextFields.append(classTextField)
                //                editButtons.append(editButton)
                //                doneButtons.append(doneButton)
//                cell?.addSubview(activeClassLabel)
                //                cell?.addSubview(doneButton)
                cell?.addSubview(classLabel)
//                                cell?.addSubview(editButton)
                cell?.addSubview(classTextField)
                cells.append(cell!)
//            }
            
            
        } else if indexPath.row == classes.count + 1 && indexPath.row < 5 {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
            cell?.addSubview(plusButton)
            
            
        } else if indexPath.row == Int(numSmallRows) {
            
            for subview in (cell?.subviews)! {
                subview.removeFromSuperview()
            }
            
//            cell?.addSubview(saveButton)
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        
        if indexPath.row == 0 {
            return 260
        } else {
            return (self.tableView.frame.size.height - 260)/5
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 && cells.count >= indexPath.row && classTextFields[indexPath.row - 1].text?.characters.count >= 2 {
        
            
            var newActiveClass = ""
            if editMode == true {
                newActiveClass = classTextFields[indexPath.row - 1].text!
            } else {
                newActiveClass = classLabels[indexPath.row - 1].text!
            }
            
            activeClassLabel.text = "ACTIVE CLASS: " + newActiveClass
            activeClassQuery(newActiveClass)
            
//            if currActiveClassLabel.hidden == true {
//                for activeClassLabel in activeClassLabels {
//                    activeClassLabel.hidden = true
//                    activeClassLabel.alpha = 0
//                }
//                currActiveClassLabel.hidden = false
//                UIView.animateWithDuration(0.25, animations: {
//                    currActiveClassLabel.alpha = 1
//                })
//                
//                activeClassQuery(classes[indexPath.row - 1])
//                
//            } else {
//                currActiveClassLabel.hidden = true
//                UIView.animateWithDuration(0.25, animations: {
//                    currActiveClassLabel.alpha = 0
//                })
//            }
            //tableView.reloadData()
        }
        //tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 && classTextFields.count >= indexPath.row - 1 {
            var updatedClasses = Array<String>()
            var currActiveClass = ""
            for (var i = 0; i < classLabels.count; i++) {
                if classLabels[i].alpha != 0 {
                  
                    updatedClasses.append(classLabels[i].text!)

                }
                if classTextFields[i].alpha != 0 {
                  
                    updatedClasses.append(classTextFields[i].text!)
                    
                }
            }
            print("the length is ")
            print(updatedClasses)
            updatedClasses.removeAtIndex(indexPath.row - 1)
            
            if currActiveClass == "" {
                currActiveClass = (classLabels.first?.text)!
            }
            var currClass = classes[indexPath.row - 1]
            classes.removeAtIndex(indexPath.row - 1)
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["user_courses"] = updatedClasses
                        object["activeClass"] = currActiveClass
                        object.saveInBackgroundWithBlock {
                            (success, error) in
                            if success == true {
                                self.classes = Array<String>()
                                self.cells = Array<UITableViewCell>()
                                self.editButtons = Array<UIButton>()
                                self.doneButtons = Array<UIButton>()
                                self.classTextFields = Array<UITextField>()
                                self.classLabels = Array<UILabel>()
                                self.activeClassLabels = Array<UILabel>()
                                
                                self.getCurrUserObject()
//                                self.tableView.reloadData()
                            } else {
                                
                            }
                        }
             
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        }
        
    }
    
    func editButtonPressed(sender: UIButton) {
        editMode = true
        editButton.alpha = 0
        self.saveButton.alpha = 1
        self.plusButton.hidden = false
        self.plusButton.alpha = 1
        for classTextField in self.classTextFields {
            classTextField.hidden = false
            classTextField.alpha = 1
            classTextField.removeFromSuperview()
        }
        for classLabel in self.classLabels {
            classLabel.alpha = 0
            classLabel.hidden = true
            classLabel.removeFromSuperview()
        }
        self.cells = Array<UITableViewCell>()
        self.editButtons = Array<UIButton>()
        self.doneButtons = Array<UIButton>()
        self.classTextFields = Array<UITextField>()
        self.classLabels = Array<UILabel>()
        self.activeClassLabels = Array<UILabel>()
        self.tableView.reloadData()
    }
    
    func doneButtonPressed(sender: UIButton) {
        self.view.bringSubviewToFront(editButton)
        saveButton.alpha = 0
        var currButtonIndex = sender.tag
        var currEditButton = editButtons[currButtonIndex]
        var currDoneButton = doneButtons[currButtonIndex]
        var currClassTextField = classTextFields[currButtonIndex]
        var currClassLabel = classLabels[currButtonIndex]
        currClassLabel.text = currClassTextField.text
        currClassTextField.hidden = true
        currDoneButton.hidden = true
        UIView.animateWithDuration(0.25, animations: {
            currDoneButton.alpha = 0
            currEditButton.alpha = 1
            currClassTextField.alpha = 0
            currClassLabel.alpha = 1
        })
        
    }
    
    func plusButtonPressed(sender: UIButton) {
        plusButton.removeFromSuperview()
        classes.append("")
        for label in classLabels {
            label.removeFromSuperview()
        }
        
        for textField in classTextFields {
            textField.removeFromSuperview()
        }
        self.cells = Array<UITableViewCell>()
        self.editButtons = Array<UIButton>()
        self.doneButtons = Array<UIButton>()
        self.classTextFields = Array<UITextField>()
        self.classLabels = Array<UILabel>()
        self.activeClassLabels = Array<UILabel>()
        
        tableView.reloadData()
//
//        UIView.animateWithDuration(0.25, animations: {
//            for classTextField in self.classTextFields {
//                classTextField.hidden = false
//                classTextField.alpha = 1
//                classTextField.placeholder = "<your class here>"
//            }
//            for classLabel in self.classLabels {
//                classLabel.alpha = 0
//                classLabel.hidden = true
//            }
//        })
        
    }
    
    func saveClasses() {
        editMode = false
        self.plusButton.hidden = true
        self.plusButton.alpha = 0
        self.editButton.hidden = false
        self.editButton.alpha = 1
        HUD.textLabel.text = "Saving..."
        HUD.showInView(view)
        var updatedClasses = Array<String>()
        var currActiveClass = ""
        for (var i = 0; i < classLabels.count; i++) {
            if classLabels[i].alpha != 0 {
                if updatedClasses.contains(classLabels[i].text!) == false {
                    updatedClasses.append(classLabels[i].text!)
                }
                
                if activeClassLabels[i].alpha != 0 {
                    currActiveClass = classLabels[i].text!
                }
            }
            if classTextFields[i].alpha != 0 {
                if updatedClasses.contains(classTextFields[i].text!) == false {
                    updatedClasses.append(classTextFields[i].text!)
                }
                
            }
        }
        
        if currActiveClass == "" {
            currActiveClass = (classLabels.first?.text)!
        }
        
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["user_courses"] = updatedClasses
                        object["activeClass"] = currActiveClass
                        object.saveInBackgroundWithTarget(nil, selector: nil)
                        self.classes = updatedClasses
                        self.saveButton.alpha = 0
                        self.HUD.dismiss()
                    }
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        for classLabel in classLabels {
            classLabel.hidden = false
            classLabel.alpha = 1
        }
        
        for classTextField in classTextFields {
            if classTextField.hidden == false {
                classLabels[classTextFields.indexOf(classTextField)!].text = classTextField.text
            }
            
            classTextField.hidden = true
            classTextField.alpha = 0
        }
        self.cells = Array<UITableViewCell>()
        self.editButtons = Array<UIButton>()
        self.doneButtons = Array<UIButton>()
        self.classTextFields = Array<UITextField>()
        self.classLabels = Array<UILabel>()
        self.activeClassLabels = Array<UILabel>()
        tableView.reloadData()
        
    }
    
    
    func activeClassQuery(className: String) {
        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        object["activeClass"] = className
                        object.saveInBackgroundWithTarget(nil, selector: nil)
                    }
                    self.cells = Array<UITableViewCell>()
                    self.editButtons = Array<UIButton>()
                    self.doneButtons = Array<UIButton>()
                    self.classTextFields = Array<UITextField>()
                    self.classLabels = Array<UILabel>()
                    self.activeClassLabels = Array<UILabel>()
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    // Creates a UIColor from a Hex string.
    func colorWithHexString (hex:String) -> UIColor {
        var cString:String = hex.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).uppercaseString
        
        if (cString.hasPrefix("#")) {
            cString = (cString as NSString).substringFromIndex(1)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.grayColor()
        }
        
        let rString = (cString as NSString).substringToIndex(2)
        let gString = ((cString as NSString).substringFromIndex(2) as NSString).substringToIndex(2)
        let bString = ((cString as NSString).substringFromIndex(4) as NSString).substringToIndex(2)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        NSScanner(string: rString).scanHexInt(&r)
        NSScanner(string: gString).scanHexInt(&g)
        NSScanner(string: bString).scanHexInt(&b)
        
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(1))
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeField = textField
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    func beganKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWasShown:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    func endKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        self.tableView.scrollEnabled = true
        var userInfo : NSDictionary = notification.userInfo!
        var keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var insets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height + 50, 0.0)
        
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        
        var rect : CGRect = self.view.frame
        rect.size.height -= keyboardSize!.height
        if let activeFieldPresent = activeField {
            if (!CGRectContainsPoint(rect, activeField!.frame.origin))
            {
                self.tableView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
        
        
    }
    
    
    func keyboardWillBeHidden(notification: NSNotification) {
        var userInfo : NSDictionary = notification.userInfo!
        var keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size
        var insets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -(keyboardSize!.height + 50), 0.0)
        self.tableView.contentInset = insets
        self.tableView.scrollIndicatorInsets = insets
        self.view.endEditing(true)
        self.tableView.scrollEnabled = false
        
    }
    
    
    func textFieldDidEndEditing(textField: UITextField!) {
        activeField = nil
    }
    
    func dismissKeyboard() {
        activeField!.resignFirstResponder()
    }
    func showContentAlert() {
        
        var subtitleText = "Please make sure that you do not share any content that could be offensive to others and that you conduct yourself on this app in a friendly manner. Groupit does not tolerate any form of bullying or offensive content. If you violate these rules, you may be permanently banned from this app."
        
        var popupTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.mainScreen().bounds.width - 40, height: 40))
        var popupOkayButton = UIButton()
        var popupSubtitleLabel = UILabel()
        
        popupTitleLabel.font = UIFont.systemFontOfSize(15)
        popupTitleLabel.textColor = Constants.lightGreenColor
        popupTitleLabel.textAlignment = .Center
        popupTitleLabel.text = "USER CONTENT AGREEMENT"
        popupSubtitleLabel.font = UIFont.systemFontOfSize(15)
        popupSubtitleLabel.text = subtitleText
        popupSubtitleLabel.adjustsFontSizeToFitWidth = true
        var contentString = subtitleText
        var maximumLabelSize: CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 78, 1000)
        var options: NSStringDrawingOptions = [.TruncatesLastVisibleLine, .UsesLineFragmentOrigin]
        var attr : [String: AnyObject] = [NSFontAttributeName:  UIFont.systemFontOfSize(15)]
        var labelBounds: CGRect = contentString.boundingRectWithSize(maximumLabelSize, options: options, attributes: attr, context: nil)
        var labelHeight: CGFloat = labelBounds.size.height
        popupSubtitleLabel.lineBreakMode = .ByWordWrapping
        popupSubtitleLabel.numberOfLines = 0
        
        
        popupSubtitleLabel.frame = CGRect(x: 10, y: 45, width: Int(UIScreen.mainScreen().bounds.width) - 40, height: Int(labelHeight))
        var popupViewHeight = 10 + popupTitleLabel.frame.height + 5 + popupSubtitleLabel.frame.height + 10 + 40 + 10
        popupView.frame = CGRect(x: 10, y: (UIScreen.mainScreen().bounds.height-popupViewHeight)/2, width: UIScreen.mainScreen().bounds.width - 20, height: popupViewHeight)
        popupOkayButton.frame = CGRect(x: 10, y: popupView.frame.height - 50, width: popupView.frame.width - 20, height: 40)
        popupOkayButton.setTitle("OKAY, GOT IT", forState: .Normal)
        popupOkayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        popupOkayButton.titleLabel?.textColor = Constants.lightGreenColor
        popupOkayButton.titleLabel!.font = UIFont(name: "Gujarati Sangam MN", size: 20)
        popupOkayButton.backgroundColor = Constants.lightGreenColor
        popupOkayButton.addTarget(self, action: "dismissAlert", forControlEvents: .TouchUpInside)
        popupView.backgroundColor = UIColor.whiteColor()
        popupView.addSubview(popupTitleLabel)
        popupView.addSubview(popupSubtitleLabel)
        popupView.addSubview(popupOkayButton)
        popupView.bringSubviewToFront(popupOkayButton)
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        popupConfig.showCompletion = { popupView in
            
        }
        popupConfig.dismissCompletion = { popupView in
            popupTitleLabel.removeFromSuperview()
            popupSubtitleLabel.removeFromSuperview()
            popupOkayButton.removeFromSuperview()
            
        }
        
        presentPopupView(popupView, config: popupConfig)
        
    }
    
    func dismissAlert() {
        showAlert = false
        dismissPopupView()
    }
    
}
