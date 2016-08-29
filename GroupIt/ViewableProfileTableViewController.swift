//
//  ViewableProfileTableViewController.swift
//  GroupIt
//
//  Created by Sona Jeswani on 4/6/16.
//  Copyright © 2016 Sona and Ally. All rights reserved.
//

import UIKit
import Parse

class ViewableProfileTableViewController: UITableViewController {

    
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var classOne: UILabel!
    
    @IBOutlet weak var classTwo: UILabel!
    
    @IBOutlet weak var classThree: UILabel!
    
    @IBOutlet weak var classFour: UILabel!
    
    var classArray = [String](count: 4, repeatedValue: "")
    
    
    @IBOutlet weak var username: UILabel!
    
    var currUserObject: PFObject!
    var profPicFile: PFFile!
    
    var currChatObject = Array<PFObject>()
    var otherUserId = ""
    var otherUserName = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        profilePic.contentMode = .ScaleAspectFill
        profilePic.layer.borderColor = Constants.greenColor.CGColor
        profilePic.layer.borderWidth = 2
        profilePic.clipsToBounds = true
        profilePic.layer.cornerRadius = profilePic.bounds.width + 5
        
        
        
        if currChatObject.first!["nameOne"] as! String == PFUser.currentUser()?.username {
            otherUserId = currChatObject.first!["userTwo"] as! String
            profPicFile = currChatObject.first!["userTwoProfPic"] as! PFFile
            otherUserName = currChatObject.first!["nameTwo"] as! String
            
        } else {
            otherUserId = currChatObject.first!["userOne"] as! String
            profPicFile = currChatObject.first!["userOneProfPic"] as! PFFile
            otherUserName = currChatObject.first!["nameOne"] as! String
        }
        
        getCurrUserObject()
        getProfilePic()
        self.username.text = otherUserName
        
        self.classOne.text = classArray[0]
        self.classTwo.text = classArray[1]
        self.classThree.text = classArray[2]
        self.classFour.text = classArray[3]
        


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
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
       
        if section == 0 {
            return 1
        }
        else {
            return 4
        }

       
    }
    
    
        
    func getCurrUserObject() {
        
        
        var elem = ""

        var query = PFQuery(className:"_User")
        query.whereKey("objectId", equalTo: otherUserId)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) classes.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.currUserObject = objects.first
                        if self.currUserObject["user_courses"] != nil {
                            
                            //self.classes = self.currUserObject["user_courses"] as! Array<String>
                            var numClasses = self.currUserObject["user_courses"].count
                            for index in 0...numClasses - 1 {
                                
                                elem = (self.currUserObject["user_courses"] as! Array<String>)[index] as! String
                                //elem = self.currUserObject["user_courses"][index] as! String
                                self.classArray[index] = elem as! String
                                print("class ", self.classArray[index])
                                //self.classOne.text = self.classArray[index]
                            }
                            
                            

                        }

                        self.tableView.reloadData()
                    }
                }
                self.classOne.text = self.classArray[0]
                self.classTwo.text = self.classArray[1]
                self.classThree.text = self.classArray[2]
                self.classFour.text = self.classArray[3]
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    
    func getProfilePic() {
        profPicFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                var image1 = UIImage(data:imageData!)
                self.profilePic.image = image1
            } else {
                print(error)
            }
        }
    }
    
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 175
        }
        else {
            return 45
        }
        
        }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

