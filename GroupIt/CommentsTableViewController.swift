//
//  CommentsTableViewController.swift
//  GroupIt
//
//  Created by Ally Koo on 4/24/16.
//  Copyright © 2016 Akkshay Khoslaa. All rights reserved.
//

import UIKit
import Parse

class CommentsTableViewController: UITableViewController {

    var postInfo: PFObject!
    var commentObjects = Array<PFObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("headerComment", forIndexPath: indexPath) as! HeaderCommentTableViewCell

        if indexPath.row == 0 {
            
            cell.classTitle.text = postInfo["classTitle"] as! String
            cell.username.text = postInfo["poster"] as! String
            cell.postBodyText.text = postInfo["message"] as! String
            //cell.profPic. = postInfo["profilePic"]
            cell.postBodyText.layer.borderWidth = 1
            
            postInfo["profilePic"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    cell.profilePic.image = nil
                    
                    cell.profilePic.image = UIImage(data:imageData!)
                    cell.profilePic.layer.cornerRadius = cell.profilePic.frame.size.width/2
                    cell.profilePic.clipsToBounds = true
                    
                }
            
        }
        }else {
            let thecell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath) as! CommentsTableViewCell
            getComment()
            thecell.commentBodyText.text = self.commentObjects[indexPath.row]["comment"] as! String
            thecell.username.text = self.commentObjects[indexPath.row]["username"] as! String
            commentObjects[indexPath.row]["profilePic"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    thecell.profPic.image = nil
                    
                    thecell.profPic.image = UIImage(data:imageData!)
                    thecell.profPic.layer.cornerRadius = thecell.profPic.frame.size.width/2
                    thecell.profPic.clipsToBounds = true
                    
                }
                
            }

            
            
            }

        return cell
    }
    
    func getComment() {
        commentObjects = Array<PFObject>()
        var query = PFQuery(className: "Comments")
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    print("COUNT", objects.count)
                    self.commentObjects = objects
                    //self.numPosts = objects.count
                    //print(self.postObjects)
                    
                    //for postObject in self.postObjects {
                    //self.nameToUserDict[userObject["username"] as! String] = postObject
                    //}
                    //self.membersTableView.reloadData()
                    
                    self.tableView!.reloadData()
                    
                    
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }

        
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 200
        }
        else {
            return 100
        }
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
