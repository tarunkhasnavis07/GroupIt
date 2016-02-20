//
//  ChatsTableViewController.swift
//  ParseStarterProject
//
//  Created by Tarun Khasnavis on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import Parse

class ChatsTableViewController: UITableViewController {

    
    
    var chatObjects = Array<PFObject>()
    var currChatIndex = 0
    var refresher:UIRefreshControl!
    var takeDirect = false
    var lightColor = UIColor.grayColor()
    var darkColor = UIColor.grayColor()
    var gColor = UIColor.grayColor()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        gColor = colorWithHexString ("#696969")
        
        
//        self.tableView.backgroundColor = UIColor.clearColor()
//        self.view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action:"refresh", forControlEvents:UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
        
        
        getChats()
//        self.navigationController!.navigationBar.hidden = false
//        self.navigationController?.navigationBar.barTintColor = Constants.lightGreenColor
//        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
//        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController?.navigationBar.barTintColor = Constants.lightBlueColor
//        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
//        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
    }
    
    func getChats() {
        var allChatUids = Array<String>()
        
        let relevantChatsQueryOne = PFQuery(className:"Chats")
        relevantChatsQueryOne.whereKey("userOne", equalTo: (PFUser.currentUser()?.objectId)!)
        relevantChatsQueryOne.orderByDescending("createdAt")
        do {
            let objects = try relevantChatsQueryOne.findObjects()
            
            for object in objects {
                allChatUids.append(object.objectId! as! String)
            }
            
            if takeDirect == true {
                
            }
            
        } catch {
            print("Error")
        }
        
        
        let relevantChatsQueryTwo = PFQuery(className:"Chats")
        relevantChatsQueryTwo.whereKey("userTwo", equalTo: (PFUser.currentUser()?.objectId)!)
        relevantChatsQueryTwo.orderByDescending("createdAt")
        do {
            let objects = try relevantChatsQueryTwo.findObjects()
            
            for object in objects {
                allChatUids.append(object.objectId! as! String)
            }
            
        } catch {
            print("Error")
        }
        
        print("all chats are")
        print(allChatUids)
        
        var query = PFQuery(className:"Chats")
        query.whereKey("objectId", containedIn: allChatUids)
        query.orderByDescending("updatedAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    self.chatObjects = objects
                    self.tableView.reloadData()
                    self.refresher.endRefreshing()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
       
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatObjects.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatsCell", forIndexPath: indexPath) as! ChatsTableViewCell
        
        cell.backgroundColor = UIColor.whiteColor()
        
        cell.daysAgo.textColor = Constants.greenColor
        
        cell.daysAgo.font = UIFont.systemFontOfSize(10)
        cell.username.font = UIFont.systemFontOfSize(18.0)
        cell.username.textColor = Constants.greenColor
        cell.message.font = UIFont.systemFontOfSize(13)
        cell.message.textColor = UIColor.grayColor()
        if (PFUser.currentUser()?.objectId)! == chatObjects[indexPath.row]["userOne"] as! String {
            cell.username.text = chatObjects[indexPath.row]["nameTwo"] as! String
            chatObjects[indexPath.row]["userTwoProfPic"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    cell.profPic.image = UIImage(data:imageData!)
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width/2
                    cell.profPic.clipsToBounds = true
                    
                } else {
                    print(error)
                }
            }
            var youString = ""
            if (chatObjects[indexPath.row]["lastMessageFrom"] as! String) == PFUser.currentUser()?.username {
                youString = "You: "
            } else {
                var lastMessageSeen = chatObjects[indexPath.row]["lastMessageSeen"] as! Bool
                if lastMessageSeen == false {
                    cell.daysAgo.textColor = UIColor.greenColor()
                    cell.daysAgo.font = UIFont.boldSystemFontOfSize(10)
                    cell.username.font = UIFont.boldSystemFontOfSize(18.0)
                    cell.message.font = UIFont.boldSystemFontOfSize(13)
                }
            }
            var messageString = youString + (chatObjects[indexPath.row]["lastMessage"] as! String)
            cell.message.text = messageString
            
            
            
        } else {
            cell.username.text = chatObjects[indexPath.row]["nameOne"] as! String
            chatObjects[indexPath.row]["userOneProfPic"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    cell.profPic.image = UIImage(data:imageData!)
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width/2
                    cell.profPic.clipsToBounds = true
                    
                } else {
                    print(error)
                }
            }
            var youString = ""
            if (chatObjects[indexPath.row]["lastMessageFrom"] as! String) == PFUser.currentUser()?.username {
                youString = "You: "
            } else {
                var lastMessageSeen = chatObjects[indexPath.row]["lastMessageSeen"] as! Bool
                if lastMessageSeen == false {
                    cell.daysAgo.textColor = UIColor.greenColor()
                    cell.daysAgo.textColor = UIColor.greenColor()
                    cell.daysAgo.font = UIFont.boldSystemFontOfSize(10)
                    cell.username.font = UIFont.boldSystemFontOfSize(18.0)
                    cell.message.font = UIFont.boldSystemFontOfSize(13)
                }
            }
            var messageString = youString + (chatObjects[indexPath.row]["lastMessage"] as! String)
            cell.message.text = messageString
            
            
        }
        
        var timePassedString = ""
        var postTime:NSDate? = chatObjects[indexPath.row].updatedAt!
        var currDate = NSDate()
        var passedTime:NSTimeInterval = currDate.timeIntervalSinceDate(postTime!)
        if Double(passedTime) < 60.0 {
            timePassedString = String(Int(Double(passedTime)))
            timePassedString += " secs ago"
        } else if Double(passedTime) < 3600.0 {
            timePassedString = String(Int(Double(passedTime)/60))
            timePassedString += " mins ago"
        } else if Double(passedTime) < 86400.0 {
            timePassedString = String(Int(Double(passedTime)/3600))
            timePassedString += " hrs ago"
        } else {
            timePassedString = String(Int(Double(passedTime)/86400.0))
            timePassedString += " days ago"
        }
        cell.daysAgo.text = timePassedString
        
        
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toChatVC" {
            let navVC = segue.destinationViewController as! UINavigationController
            let chatVC = navVC.topViewController as! ChatViewController
            var chatObjectArr = [chatObjects[currChatIndex]]
            chatVC.currChatObjects = chatObjectArr
        }
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        currChatIndex = indexPath.row
        self.performSegueWithIdentifier("toChatVC", sender: self)
    }
    
    func refresh() {
        chatObjects = Array<PFObject>()
        getChats()
    }
    
    override func viewDidAppear(animated: Bool) {
        refresh()
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

}