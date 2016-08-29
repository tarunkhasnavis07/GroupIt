//
//  ForumCollectionViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/21/16.
//  Copyright © 2016 Sona and Ally. All rights reserved.
//

import UIKit
import Parse

private let reuseIdentifier = "Cell"



class ForumCollectionViewController: UICollectionViewController {
    
    var postObjects = Array<PFObject>()

    var index = 0
    var numPosts = 5
    @IBOutlet weak var postText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
        //print(self.postObjects.count)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        //self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        //print("num rows is ", self.postObjects.count)
        //return self.postObjects.count
        return self.numPosts
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("forumCell", forIndexPath: indexPath) as! ForumCollectionViewCell
        
        //let query = PFQuery(className:"_User")
       
        
        //for post in postObjects {
        if postObjects.count > indexPath.row {
            cell.postBodyText.text = postObjects[indexPath.row]["message"] as! String
            print("message is ", postObjects[indexPath.row]["message"])
            cell.username.text = postObjects[indexPath.row]["poster"] as! String
            cell.postMainText.text = postObjects[indexPath.row]["classTitle"] as! String
            //var userID = post["poster"] as! String
            print("user id is ", postObjects[indexPath.row]["poster"])
            postObjects[indexPath.row]["profilePic"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    cell.profPic.image = nil
                    
                    cell.profPic.image = UIImage(data:imageData!)
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width/2
                    cell.profPic.clipsToBounds = true

                }

            }

        }
        
    
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toComments" {
            let navVC = segue.destinationViewController as! CommentsTableViewController
            //let profileVC = navVC.topViewController as! ViewableProfileTableViewController
            //var chatObjectArr = [chatObjects[currChatIndex]]
            //chatVC.currChatObjects = chatObjectArr
            //             if currChatObjects.first!["nameOne"] as! String == PFUser.currentUser()?.username {
            //                profileVC.currUserObject = currChatObjects.first!
            //            profileVC.currUserObject = otherUserObjectId
            navVC.postInfo = postObjects[index] as! PFObject
        }
    }

    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.index = indexPath.row
       self.performSegueWithIdentifier("toComments", sender: self)
        
        
    }
    
//    func getUser(userID: Int) {
//        let query = PFQuery(className:"_User")
//        query.whereKey("objectId", equalTo:(userID))
//        query.findObjectsInBackgroundWithBlock {
//        (objects: [PFObject]?, error: NSError?) -> Void in
//        
//        if error == nil {
//            // The find succeeded.
//            //print("Successfully retrieved \(objects!.count) users.")
//            // Do something with the found objects
//            if let objects = objects! as? [PFObject] {
//                for object in objects {
//                    print("username is ", object["username"])
//                cell.username.text = object["username"] as! String
//                var profPicFile = object["profilePicture"] as! PFFile
//                profPicFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//                    if error == nil {
//                        var image1 = UIImage(data:imageData!)
//                        cell.profPic.image = image1
//                    } else {
//                        print(error)
//                    }
//                }
//            }
//        
//        print("COUNT", objects.count)
//        self.postObjects = objects
//        print(self.postObjects)
//        
//        for postObject in self.postObjects {
//        self.nameToUserDict[userObject["username"] as! String] = postObject
//        }
//        self.membersTableView.reloadData()
//        
//        self.tableView.reloadData()
//        
//        
//                            }
//                        } else {
//                            // Log details of the failure
//                            print("Error: \(error!) \(error!.userInfo)")
//                        }
//        }
//        
//                    object["profilePicture"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//                        if error == nil {
//        
//                            cell.cellProfilePic.image = nil
//        
//                            cell.cellProfilePic.image = UIImage(data:imageData!)
//                            cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
//                            cell.cellProfilePic.clipsToBounds = true
//        
//        
//        
//        
//                        } else {
//                            print(error)
//                        }
//                    }
//        
//        cell.postMainText.text = object["message"] as! String
//    }
    
    func getPosts() {
        postObjects = Array<PFObject>()
        
        let query = PFQuery(className:"Forum")
        
        print(PFUser.currentUser())
  
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    print("COUNT", objects.count)
                    self.postObjects = objects
                    self.numPosts = objects.count
                    print(self.postObjects)
                    
                    //for postObject in self.postObjects {
                        //self.nameToUserDict[userObject["username"] as! String] = postObject
                    //}
                    //self.membersTableView.reloadData()
                    
                    self.collectionView!.reloadData()
                    
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
