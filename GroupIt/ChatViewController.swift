//
//  ChatViewController.swift
//  ParseStarterProject
//
//  Created by Tarun Khasnavis on 11/30/15.
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Foundation
import MediaPlayer
import Parse
import STZPopupView
class ChatViewController: JSQMessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var currChatObjects = Array<PFObject>()
    var timer: NSTimer = NSTimer()
    var isLoading: Bool = false
    var bubbleFactory = JSQMessagesBubbleImageFactory()
    var outgoingBubbleImage: JSQMessagesBubbleImage!
    var incomingBubbleImage: JSQMessagesBubbleImage!
    var allMessages = Array<String>()
    var blankAvatarImage: JSQMessagesAvatarImage!
    var messages = Array<JSQMessage>()
    var chatUid = ""
    var avatars = Dictionary<String, JSQMessagesAvatarImage>()
    var usernames = Array<String>() //Current user's username is first in this array
    var profPics = Array<PFFile>() //Current user's profile picture is first in this array
    var twoProfPics = Array<PFFile>()
    var numImagesToSend = 0
    var sendingImages = false
    var otherUserObjectId = ""
    var lightColor = UIColor.grayColor()
    var darkColor = UIColor.grayColor()
    var gColor = UIColor.grayColor()
    var popupView = UIView(frame: CGRect(x: 10, y: (UIScreen.mainScreen().bounds.height-200)/2, width: UIScreen.mainScreen().bounds.width - 20, height: 200))
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(usernames.count)
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        gColor = colorWithHexString ("#696969")
        
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "green_navbar_clear.jpg"), forBarMetrics: UIBarMetrics.Default)
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: Constants.lightGreenColor]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary

        
//        self.view.backgroundColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1)
        self.collectionView?.backgroundColor = UIColor.clearColor()
//        
//        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
//        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
//        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        self.senderId = PFUser.currentUser()?.username
        self.senderDisplayName = PFUser.currentUser()?.username
        if currChatObjects.first!["nameOne"] as! String == PFUser.currentUser()?.username {
            twoProfPics.append(currChatObjects.first!["userOneProfPic"] as! PFFile)
            twoProfPics.append(currChatObjects.first!["userTwoProfPic"] as! PFFile)
            self.title = currChatObjects.first!["nameTwo"] as! String
            otherUserObjectId = currChatObjects.first!["userTwo"] as! String
        } else {
            twoProfPics.append(currChatObjects.first!["userTwoProfPic"] as! PFFile)
            twoProfPics.append(currChatObjects.first!["userOneProfPic"] as! PFFile)
            self.title = currChatObjects.first!["nameOne"] as! String
            otherUserObjectId = currChatObjects.first!["userOne"] as! String
            
        }
        
        
        chatUid = currChatObjects.first!.objectId! as! String
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(Constants.greenColor)
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(Constants.lightGreenColor)
        
        blankAvatarImage = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "maleUser"), diameter: 30)
        isLoading = false
        self.loadMessages()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(false)
        timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "loadMessages", userInfo: nil, repeats: true)
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewDidDisappear(false)
        timer.invalidate()
    }
    
    func loadMessages() {
        
        print("printing now")
        print(currChatObjects.first!.objectId! as! String)
        
        var query = PFQuery(className:"Messages")
        query.whereKey("chatUid", equalTo: currChatObjects.first!.objectId! as! String)
        var lastMessage = messages.last
        if lastMessage != nil {
            query.whereKey("createdAt", greaterThan: (lastMessage?.date)!)
        }
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    
                    self.automaticallyScrollsToMostRecentMessage = false
                    for object in objects {
                        self.addMessage(object)
                    }
                    if objects.count > 0 {
                        self.finishReceivingMessage()
                        self.scrollToBottomAnimated(false)
                    }
                    self.automaticallyScrollsToMostRecentMessage = true
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        
        
    }
    
    func addMessage(object: PFObject) {
        var message: JSQMessage!
        
        
        
        var name = object["createdBy"] as! String
        var pictureFile = object["pictureFile"] as? PFFile
        
        if pictureFile == nil {
            message = JSQMessage(senderId: name, senderDisplayName: name, date: object.createdAt, text: (object["content"] as? String))
        }
        
        
        
        
        
        
        if pictureFile != nil {
            var mediaItem = JSQPhotoMediaItem(image: nil)
            mediaItem.appliesMediaViewMaskAsOutgoing = (name == self.senderId)
            message = JSQMessage(senderId: name, senderDisplayName: name, date: object.createdAt, media: mediaItem)
            
            pictureFile!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    mediaItem.image = UIImage(data: imageData!)
                    self.collectionView!.reloadData()
                    self.numImagesToSend = self.numImagesToSend - 1
                    if self.numImagesToSend == 0 {
                        self.sendingImages = false
                    }
                } else {
                    print(error)
                }
            }
            
            
        }
        
        
        self.usernames.append(name)
        messages.append(message)
    }
    
    func sendMessage(var text: String, picture: UIImage?) {
        var pictureFile: PFFile!
        
        
        
        let object = PFObject(className: "Messages")
        object["createdBy"] = PFUser.currentUser()?.username
        object["chatUid"] = self.chatUid
        object["content"] = text
        object["sentTo"] = self.title
        
        var notificationText = (PFUser.currentUser()?.username)! + ": " + text
        
        if let picture = picture {
            text = "[Picture message]"
            pictureFile = PFFile(name: "picture.jpg", data: UIImageJPEGRepresentation(picture, 0.6)!)
            object["pictureFile"] = pictureFile
            notificationText = (PFUser.currentUser()?.username)! + " sent you a picture."
        }
        
        object.saveInBackgroundWithBlock {
            (success, error) in
            if success == true {
                var messageUid = object.objectId
                print("message uid is" + messageUid!)
                
                var query = PFQuery(className:"Chats")
                query.whereKey("objectId", equalTo: self.currChatObjects.first!.objectId! as! String)
                query.findObjectsInBackgroundWithBlock {
                    (objects: [PFObject]?, error: NSError?) -> Void in
                    
                    if error == nil {
                        // The find succeeded.
                        print("Successfully retrieved \(objects!.count) scores.")
                        // Do something with the found objects
                        if let objects = objects {
                            for object in objects {
                                object.addUniqueObject(messageUid!, forKey: "messageUids")
                                object["lastMessage"] = text
                                object["lastMessageFrom"] = PFUser.currentUser()?.username
                                object.saveInBackgroundWithTarget(nil, selector: nil)
                            }
                            
                        }
                    } else {
                        // Log details of the failure
                        print("Error: \(error!) \(error!.userInfo)")
                    }
                }
                
            } else {
                
            }
        }
        
        /* THIS CODE IS NEEDED, UNCOMMENT LATER WHEN PUSH NOTIFICATIONS ARE CONFIGURED */
        
//        let pushQuery = PFInstallation.query()
//        pushQuery!.whereKey("userObjectId", equalTo: otherUserObjectId)
//        
//        let push = PFPush()
//        push.setQuery(pushQuery)
//        push.setMessage(notificationText)
//        push.sendPushInBackground()
        
        self.loadMessages()
        
        self.finishSendingMessage()
    }
    
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        self.sendMessage(text, picture: nil)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        
        }
    
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return outgoingBubbleImage
        }
        return incomingBubbleImage
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        var username = self.usernames[indexPath.item]
        if self.avatars[username] == nil {
            var thumbnailFile:PFFile
            if username == PFUser.currentUser()?.username {
                thumbnailFile = twoProfPics[0]
            } else {
                thumbnailFile = twoProfPics[1]
            }
            thumbnailFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    self.avatars[username] = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(data: imageData!), diameter: 30)
                    self.collectionView!.reloadData()
                }
            }
            return blankAvatarImage
        } else {
            return self.avatars[username]
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        if indexPath.item % 3 == 0 {
            let message = self.messages[indexPath.item]
            return JSQMessagesTimestampFormatter.sharedFormatter().attributedTimestampForDate(message.date)
        }
        return nil;
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return nil
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return nil
            }
        }
        return NSAttributedString(string: message.senderDisplayName)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.messages.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            cell.textView?.textColor = UIColor.whiteColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.item % 3 == 0 {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = self.messages[indexPath.item]
        if message.senderId == self.senderId {
            return 0
        }
        
        if indexPath.item - 1 > 0 {
            let previousMessage = self.messages[indexPath.item - 1]
            if previousMessage.senderId == message.senderId {
                return 0
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 0
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        print("didTapLoadEarlierMessagesButton")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapAvatarImageView avatarImageView: UIImageView!, atIndexPath indexPath: NSIndexPath!) {
        print("didTapAvatarImageview")
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        let message = self.messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let moviePlayer = MPMoviePlayerViewController(contentURL: mediaItem.fileURL)
                self.presentMoviePlayerViewControllerAnimated(moviePlayer)
                moviePlayer.moviePlayer.play()
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapCellAtIndexPath indexPath: NSIndexPath!, touchLocation: CGPoint) {
        print("didTapCellAtIndexPath")
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex != actionSheet.cancelButtonIndex {
            if buttonIndex == 1 {
                
            } else if buttonIndex == 2 {
                let image = UIImagePickerController()
                image.delegate = self
                image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
                image.allowsEditing = false
                self.presentViewController(image, animated: true, completion: nil)
            }
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        
        
        self.sendMessage("", picture: image)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        if messages.last?.senderId != PFUser.currentUser()?.username {
            var query = PFQuery(className:"Chats")
            query.whereKey("objectId", equalTo:chatUid)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    print("Successfully retrieved \(objects!.count) scores.")
                    if let objects = objects {
                        for object in objects {
                            object["lastMessageFrom"] = self.title!
                            object["lastMessageSeen"] = true
                            object.saveInBackgroundWithTarget(nil, selector: nil)
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }
    }
    
    @IBAction func dismissVC(sender: AnyObject) {
        if messages.last?.senderId != PFUser.currentUser()?.username {
            var query = PFQuery(className:"Chats")
            query.whereKey("objectId", equalTo:chatUid)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    print("Successfully retrieved \(objects!.count) scores.")
                    if let objects = objects {
                        for object in objects {
                            object["lastMessageFrom"] = self.title!
                            object["lastMessageSeen"] = true
                            object.saveInBackgroundWithTarget(nil, selector: nil)
                        }
                    }
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        }

        self.dismissViewControllerAnimated(true, completion: nil)
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
    @IBAction func openFlagModal(sender: AnyObject) {
        var subtitleText = "Are you sure you want to flag this user for objectionable content? We will then review the content and see if anything inappropriate should be removed."
        
        var popupTitleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: UIScreen.mainScreen().bounds.width - 40, height: 40))
        var popupOkayButton = UIButton()
        var popupSubtitleLabel = UILabel()
        popupTitleLabel.font = UIFont(name: "American Typewriter", size: 20)
        popupTitleLabel.textColor = Constants.lightGreenColor
        popupTitleLabel.textAlignment = .Center
        popupTitleLabel.text = "Flag Post"
        popupSubtitleLabel.font = UIFont(name: "American Typewriter", size: 15)
        popupSubtitleLabel.text = subtitleText
        popupSubtitleLabel.adjustsFontSizeToFitWidth = true
        let a = popupSubtitleLabel.text?.characters.count
        let b = 30
        var numLines = (a! + b - 1)/(b)
        popupSubtitleLabel.numberOfLines = numLines
        popupSubtitleLabel.frame = CGRect(x: 10, y: 45, width: Int(UIScreen.mainScreen().bounds.width) - 40, height: numLines*20)
        var popupViewHeight = 10 + popupTitleLabel.frame.height + 5 + popupSubtitleLabel.frame.height + 10 + 40 + 10
        popupView.frame = CGRect(x: 10, y: (UIScreen.mainScreen().bounds.height-popupViewHeight)/2, width: UIScreen.mainScreen().bounds.width - 20, height: popupViewHeight)
        popupOkayButton.frame = CGRect(x: 10, y: popupView.frame.height - 50, width: popupView.frame.width - 20, height: 40)
        popupOkayButton.setTitle("YES, FLAG POST", forState: .Normal)
        popupOkayButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        popupOkayButton.titleLabel?.textColor = Constants.lightGreenColor
        popupOkayButton.titleLabel!.font = UIFont(name: "Gujarati Sangam MN", size: 20)
        popupOkayButton.backgroundColor = Constants.lightGreenColor
        popupOkayButton.layer.cornerRadius = 5
        popupOkayButton.addTarget(self, action: "flagPost", forControlEvents: .TouchUpInside)
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
    
    func flagPost() {
        let query = PFQuery(className:"Chats")
        query.whereKey("objectId", equalTo: chatUid)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    var currFlags = objects.first!["flags"] as! Int
                    currFlags = currFlags + 1
                    objects.first!["flags"] = currFlags
                    objects.first?.saveInBackgroundWithTarget(nil, selector: nil)

                }
                
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
        dismissPopupView()
    }
    


}
