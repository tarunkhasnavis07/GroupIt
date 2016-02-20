//
//  ViewController.swift
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

import UIKit
import Parse
import ParseFacebookUtilsV4
import STZPopupView
struct Constants {
    static var greenColor = UIColor(red: 0.098, green: 0.71, blue: 0.992, alpha: 1)
    static var lightGreenColor = UIColor(red: 0.098, green: 0.71, blue: 0.992, alpha: 1)
}

class ViewController: UIViewController, BWWalkthroughViewControllerDelegate {
    let popupView = UIView(frame: CGRect(x: 0, y: 200, width: Int(UIScreen.mainScreen().bounds.width), height: Int(3*(((UIScreen.mainScreen().bounds.width/320) * 80) + 50))))
    @IBOutlet weak var backgroundImage: UIImageView!
    var performedLogout = false
    @IBOutlet weak var fblogin: UIButton!
    var justSignedUp = false
    @IBAction func loadFBData(sender: AnyObject) {
        
        let permissions = ["public_profile", "email", "user_friends"]
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    self.loadFacebookData() //
                    
                    user["user_courses"] = Array<String>()
                    user["activeClass"] = ""
                    user["status"] = true
                    user["flags"] = 0
                    user["location"] = PFGeoPoint(latitude: 0, longitude: 0)
                    user.saveInBackgroundWithTarget(nil, selector: nil)
                    
                    
                    print("User signed up and logged in through Facebook!") //
                    //AppDelegate.isFirstTimeUser = 1
                    self.justSignedUp = true
                    
                    
//                    self.tabBarController!.selectedIndex = 3
                } else {
                    //                    self.loadFacebookData()
                    print("User logged in through Facebook!")
                    self.performSegueWithIdentifier("toTabBarVC", sender: self)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toTabBarVC" && justSignedUp == true {
            let destVC = segue.destinationViewController as! UITabBarController
            destVC.selectedIndex = 2
            var destinationViewController = destVC.viewControllers![2] as! UINavigationController
            var finalVC = destinationViewController.topViewController as! MyProfileViewController
            finalVC.showAlert = true
        }
    }
    
    
    
    
    func animatedLogin() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 7, options: UIViewAnimationOptions.CurveEaseIn , animations: ({
            
            self.fblogin.alpha = 1
            
        }), completion: nil)
    }
    
    
    
    
    func loadFacebookData() {
        let user =  PFUser.currentUser()!
        
        // -------------------- Load and save user Information -------------------------------------
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if let userName : NSString = result.valueForKey("name") as? NSString {
                    print("User Name is: \(userName)")
                    user["username"] = userName
                } else {print("No username fetched")}
                if let userEmail : NSString = result.valueForKey("email") as? NSString {
                    print("User Email is: \(userEmail)")
                    user["email"] = userEmail
                } else  {print("No email address fetched")}
                if let userGender : NSString = result.valueForKey("gender") as? NSString {
                    print("User Gender is: \(userGender)")
                    user["gender"] = userGender
                } else {print("No gender fetched") }
                
                user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success == false{
                        print("Error")
                    } else {
                        print("User Information has been saved successfully!")
                    }
                })
            }
        })
        
        
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            if error == nil {
                if let profilePicURL : String  = (result.valueForKey("data")!).valueForKey("url") as? String {
                    print("The profile picture url is: \(profilePicURL)")
                    
                    let url = NSURL(string: profilePicURL)
                    let urlRequest = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                        (response, data, error) in
                        
                        let image = UIImage(data: data!)
                        
                        
                        
                        // ------------------ save image as png in Parse --------------------
                        let imageFile = PFFile(name: "profpic.png", data: UIImagePNGRepresentation(image!)!)
                        //                        let imageData = UIImagePNGRepresentation(self.profilePic.image)
                        
                        let friendRecord = PFObject(className: "friends")
                        friendRecord["username"] = PFUser.currentUser()!.username! as String
                        friendRecord["profpic"] = imageFile
                        
                        friendRecord.saveInBackgroundWithTarget(nil, selector: nil)
                        
                        user["profilePicture"] = imageFile
                        
                        user.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success == false{
                                print("Could not Save User Image")
                            } else {
                                self.performSegueWithIdentifier("toTabBarVC", sender: self)
                                print("ProfilePic has been saved successfully!")
                            }
                        })
                    })
                    
                } else { print("No profile pic URL fetched") }
            } else {
                print("\(error)")
            }
        })
        //        performSegueWithIdentifier("introSeg", sender: self)
    }
    
    //THE FOLLOWING WAS COMMENTED OUT BY SONA BC IT WAS CRASHING THE APP.
    
    override func viewDidAppear(animated: Bool) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if !userDefaults.boolForKey("tutorialPresented")
        {
            showContentAlert()
            
            userDefaults.setBool(true, forKey: "tutorialPresented")
            userDefaults.synchronize()
        }
        
//        if PFUser.currentUser() != nil {
//            self.performSegueWithIdentifier("toTabBarVC", sender: self)
//        }
    }
    
    func showTutorial()
    {
        // Present Tutorial
        let walkthroughVC = self.storyboard?.instantiateViewControllerWithIdentifier("walkthrough") as! BWWalkthroughViewController
        
        let pageOne = self.storyboard?.instantiateViewControllerWithIdentifier("pageOne")
        let pageTwo = self.storyboard?.instantiateViewControllerWithIdentifier("pageTwo")
        let pageThree = self.storyboard?.instantiateViewControllerWithIdentifier("pageThree")
        let pageFour = self.storyboard?.instantiateViewControllerWithIdentifier("pageFour")
        
        walkthroughVC.delegate = self
        walkthroughVC.addViewController(pageOne!)
        walkthroughVC.addViewController(pageTwo!)
        walkthroughVC.addViewController(pageThree!)
        walkthroughVC.addViewController(pageFour!)
        self.presentViewController(walkthroughVC, animated: true, completion: nil)
        
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        fblogin.alpha = 0
        self.animatedLogin()
        
        
        // Do any additional setup after loading the view, typically from a nib.
        //self.backgroundImage.image = UIImage(named: "login_green")
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "purple")!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        dismissPopupView()
        showTutorial()
    }
    
}

