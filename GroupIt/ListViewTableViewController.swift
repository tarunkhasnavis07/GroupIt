//
//  ListViewTableViewController.swift
//  ParseStarterProject
//
//  Created by Sona Jeswani on 11/19/15. --------
//  Copyright © 2015 Parse. All rights reserved.
//

import UIKit
import CoreLocation
import Parse
import JGProgressHUD
import ParseFacebookUtilsV4


class ListViewTableViewController: UITableViewController, CLLocationManagerDelegate, UISearchBarDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var newLocation: CLLocation?
    var userCount = 0;
    var ParseUserList = Array<PFObject>()
    var allUsers = Array<String>()
    var allProfPics = Array<PFFile>()
    var userObjects = Array<PFObject>()
    var lightColor = UIColor.grayColor()
    var darkColor = UIColor.grayColor()
    var toggleColor = UIColor.greenColor()
    
    var friendUsernames = Array<String>()
    var filteredStringObjects = Array<String>()
    
    var searchActive: Bool = false
    var data: [String] = []
    var filtered: [String] = []
    var nameToUserDict = Dictionary<String, PFObject>()
    var locationManager = CLLocationManager()
    var currUserGeoPoint = PFGeoPoint!()
    var filteredObjects = Array<PFObject>()
    var chatObjectToPass:PFObject!
    var locationArray = Array<PFGeoPoint>()
    var timer: NSTimer?
    var friendMode = false
    func getUsernames() {
        data = []
        
        for object in userObjects {
            data.append(object["username"] as! String);
        }
    }
    
    func timerTest() {
        print("Passed 5 seconds and the test.")
    }
    
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var friendsToggleSwitch: UISwitch!
    
    
    @IBAction func friendSwitchToggled(sender: AnyObject) {
        if self.friendsToggleSwitch.on == true {
            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
            HUD.textLabel.text = "Showing Facebook Friends"
            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
            HUD.showInView(self.view!)
            HUD.dismissAfterDelay(1.5)
            friendMode = true
            getUsers()
            //refresh()
        } else {
            friendMode = false
            getUsers()
            //refresh()
        }
    }
   
    
    
    @IBAction func didSwitchChange(sender: AnyObject) {
        
//        if self.toggleSwitch.on {
//            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAndSaveLocation", userInfo: nil, repeats: true)
//            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
//            HUD.textLabel.text = "Online"
//            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
//            HUD.showInView(self.view!)
//            HUD.dismissAfterDelay(1.0)
//            
//        }
//        else {
//            var HUD: JGProgressHUD = JGProgressHUD(style: JGProgressHUDStyle.Light)
//            HUD.textLabel.text = "Offline"
//            HUD.indicatorView = JGProgressHUDSuccessIndicatorView()
//            HUD.showInView(self.view!)
//            HUD.dismissAfterDelay(1.0)
//        }
//
//        
//        
//        var query = PFQuery(className:"_User")
//        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
//        query.findObjectsInBackgroundWithBlock {
//            (objects: [PFObject]?, error: NSError?) -> Void in
//            
//            if error == nil {
//                // The find succeeded.
//                print("Successfully retrieved \(objects!.count) scores.")
//                // Do something with the found objects
//                if let objects = objects {
//                    for object in objects {
//                        if self.toggleSwitch.on {
//                        object["status"] = true
//                        }
//                        else
//                        {
//                            object["status"] = false
//                        }
//                        
//                        object.saveInBackgroundWithTarget(nil, selector: nil)
//
//                        
//                    }
//                }
//            } else {
//                // Log details of the failure
//                print("Error: \(error!) \(error!.userInfo)")
//            }
//        }
    }
    
    
    func getFriendsArray() {
      
                
        var fbRequest = FBSDKGraphRequest(graphPath:"/me/friends", parameters: nil);

        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
            
            if error == nil {
                
                self.friendUsernames = []
                
                var resultDict = result as! NSDictionary
                
                var dataArr = resultDict.objectForKey("data") as! NSArray
                print("the count is")
                print(dataArr.count)
                for (var i = 0; i < dataArr.count; i++) {
                    var valueDict = dataArr[i] as! NSDictionary
                    var currUsername = valueDict.objectForKey("name") as! String
                    self.friendUsernames.append(currUsername)
                    print(currUsername)
                }
                
                print("the usernames are")
                print(self.friendUsernames)
                //friendUsernames = self.friendUsernames
                
                self.tableView.reloadData()
                //self.getFriendUserObjects(friendUsernames)
                
                
            } else {
                
                print("Error Getting Friends \(error)");
                
            }
        }
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
       
        
       // tableView.backgroundColor = UIColor.whiteColor()
       // self.view.backgroundColor = Constants.greenColor
        self.friendsToggleSwitch.on = false
        self.getLocationsArray() //gets all locations
        self.getFriendsArray()
        
        lightColor = colorWithHexString ("#9ddaf6")
        darkColor = colorWithHexString ("#4DA9D5")
        toggleColor = colorWithHexString("#a5e4ff")
        
        
        friendsToggleSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        self.friendsToggleSwitch.onTintColor = colorWithHexString("#3b5998")
        self.friendsToggleSwitch.tintColor = UIColor.whiteColor()
        
        //toggleSwitch.transform = CGAffineTransformMakeScale(0.75, 0.75)
        let myGrayColor = colorWithHexString ("#9ddaf6")
        //self.toggleSwitch.onTintColor = toggleColor
        //self.toggleSwitch.tintColor = UIColor.whiteColor()
        //self.toggleSwitch.backgroundColor = UIColor.whiteColor()
       // self.toggleSwitch.sendSubviewToBack(toggleSwitch)
//        self.toggleSwitch.layer.borderWidth = 1
//        self.toggleSwitch.layer.borderColor = UIColor.whiteColor().CGColor
//        self.toggleSwitch.layer.cornerRadius = 16
        
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        
        var tapToDismiss: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapToDismiss.cancelsTouchesInView = false
        self.view!.addGestureRecognizer(tapToDismiss)
        
        
        
        
//        if PFUser.currentUser()!["status"] as! Bool == false {
//            toggleSwitch.on = false
//        }
        
        self.refreshControl?.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
    

        
        self.navigationController!.navigationBar.hidden = false
        //        self.navigationController!.navigationBar.backgroundColor = UIColor(red: 0.459, green: 0.102, blue: 1, alpha: 1)
        self.navigationController!.navigationBar.barTintColor = UIColor.purpleColor()
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.titleTextAttributes = titleDict as? Dictionary
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        //self.locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
//        if CLLocationManager.locationServicesEna/.bled()  {
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//            
//        }
        
        
        getAndSaveLocation()
        
//        if toggleSwitch.on {
//        NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "getAndSaveLocation", userInfo: nil, repeats: true)
//       }
    
        
        var currLocation = locationManager.location
        currUserGeoPoint = PFGeoPoint(location: currLocation)
        if currUserGeoPoint == nil {
            currUserGeoPoint = PFGeoPoint(latitude: 0, longitude: 0)
        }

        getUsers()
        
        self.tableView.keyboardDismissMode = .Interactive
        
     
    }
    func locationManager(manager: CLLocationManager,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
            
            
            //Location permissions changed
            
    
    
    }
    
    override func viewWillDisappear(animated: Bool) {
        print("got to dissappear")
        timer?.invalidate()
        timer = nil
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [CLLocation]) {
        self.newLocation = locations.last
        print("current position: \(self.newLocation!.coordinate.longitude) , \(self.newLocation!.coordinate.latitude)")
        //        locationManager.stopUpdatingLocation()
        getAndSaveLocation()
        
    }
    
    func getAndSaveLocation() {
        
        locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
        print("getting the location")
        var currLocation = locationManager.location
        currUserGeoPoint = PFGeoPoint(location: currLocation)
        print(currUserGeoPoint.latitude)
        
        var query = PFQuery(className:"_User")
        NSLog("User: %@", (PFUser.currentUser()?.objectId)!)
        query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        if self.currUserGeoPoint != nil {
                            
                            //object["location"] = self.currUserGeoPoint
                            //print("THE LOCATION IS", self.newLocation)
                            //object["location"] = PFGeoPoint(latitude: 123, longitude: 123)
                            
                            print("CURRENTTTT position: \(self.newLocation?.coordinate.longitude) , \(self.newLocation?.coordinate.latitude)")
                            
                            object["location"] = PFGeoPoint(location: self.newLocation)
                            print("saved loc", object["location"])
                            
                        } else {
                            object["location"] = PFGeoPoint(latitude: 1234, longitude: 5678)
                        }
                        let status = object["status"] as! Bool
//                        if status == false {
//                            self.toggleSwitch.on = false
//                        } else {
//                            self.toggleSwitch.on = true
//                        }
                        print("got hereee")
                        object.saveInBackgroundWithTarget(nil, selector: nil)
                        }
                    
                    
                }
            }
             else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
        
        
    }
    
    
    
    func getLocationsArray() {
        
        print("GeT LOCATIONS ARRAY NEXT AFTER THIS STATEMENT")
//            locationManager.delegate = self
//            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//            locationManager.startUpdatingLocation()
//            print("getting the locations of all users")
//            var currLocation = locationManager.location
//            currUserGeoPoint = PFGeoPoint(location: currLocation)
//            print(currUserGeoPoint.latitude)
        
            var query = PFQuery(className:"_User")
            //query.whereKey("objectId", equalTo: (PFUser.currentUser()?.objectId)!)
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    print("SO FAR ALL GOOD")
                    if let objects = objects {
                        for object in objects {
                            if object["location"] != nil {
                                self.locationArray.append(object["location"] as! PFGeoPoint)

                            }
                                                        //object["location"] = self.currUserGeoPoint
                            //print("got hereee")
                            //object.saveInBackgroundWithTarget(nil, selector: nil)
                        }
                        
                        
                    }
                }
                else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
        for elem in self.locationArray {
//            print(elem)
        }
        print("GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS GOT LOCATIONS ARRAYS")
    }

    
    
    override func viewDidDisappear(animated: Bool) {
        
    }
    
    func refresh() {
        userCount = 0;
        ParseUserList = Array<PFObject>()
        allUsers = Array<String>()
        allProfPics = Array<PFFile>()
        userObjects = Array<PFObject>()
        
        //friendUsernames = Array<String>()
        filteredStringObjects = Array<String>()
        
        data = []
        filtered = []
        nameToUserDict = Dictionary<String, PFObject>()
        filteredObjects = Array<PFObject>()
        locationArray = Array<PFGeoPoint>()
        getFriendsArray()
        print("REFRESHING FRIENDS AND HERE THEY ARE")
        getUsers()
        self.tableView.reloadData()
        refreshControl!.endRefreshing()
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        refresh()
//        self.getFriendsArray()
        
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
//        if searchText != "" {
//            for object in userObjects {
//                if (object["username"] as! String).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil || (object["activeClass"] as! String).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil {
//                    if filteredObjects.contains(object) == false {
//                        print("adding filtered obj")
//                        filteredObjects.append(object)
//                    }
//                }
//            }
//        } else {
//            filteredObjects = userObjects
//        }
//        
        print("filtered objects are")
        print(filteredObjects)
        
        if !(searchText == "") {
            filteredObjects = userObjects.filter({ (object) -> Bool in
                let activeClass: NSString = object["activeClass"] as! String
                let username: NSString = object["username"] as! String
                let rangeOne = activeClass.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                let rangeTwo = username.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
                
                if rangeOne.location != NSNotFound || rangeTwo.location != NSNotFound {
                    return true
                } else {
                    return false
                }
                
            })
        } else {
            filteredObjects = userObjects
        }
        
        if(filteredObjects.count == 0){
            searchActive = true
            ; /*True if you want to display all results when the search text does not match any results, rather than displaying none */
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
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
        if(searchActive) {
            return filteredObjects.count
        }
        return self.userObjects.count;
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("got inside didselect")
        var userOneImageFile = PFFile(name: "blank", data: UIImagePNGRepresentation(UIImage(named: "deleteButton")!)!)
        var otherUserObjectId = ""
        if searchActive == true {
            otherUserObjectId = filteredObjects[indexPath.row].objectId!
        } else {
            otherUserObjectId = userObjects[indexPath.row].objectId!
        }
        var alreadyExists = false
        var checkQuery = PFQuery(className: "Chats")
        checkQuery.whereKey("userOne", equalTo: (PFUser.currentUser()?.objectId)!)
        do {
            let objects = try checkQuery.findObjects()
            for object in objects {
                var userTwo = object["userTwo"] as! String
                if userTwo == otherUserObjectId {
                    alreadyExists = true
                }
            }
            
        } catch {
            print("Error")
        }
        
        var checkQueryTwo = PFQuery(className: "Chats")
        checkQueryTwo.whereKey("userTwo", equalTo:(PFUser.currentUser()?.objectId)!)
        do {
            let objects = try checkQueryTwo.findObjects()
            for object in objects {
                var userOne = object["userOne"] as! String
                if userOne == otherUserObjectId {
                    alreadyExists = true
                }
            }
            
        } catch {
            print("Error")
        }
        
        
        if alreadyExists == false {
            let query = PFQuery(className:"_User")
            query.whereKey("objectId", equalTo:(PFUser.currentUser()?.objectId)!)
            query.orderByDescending("createdAt")
            do {
                let objects = try query.findObjects()
                for object in objects {
                    userOneImageFile = object["profilePicture"] as! PFFile
                }
                
            } catch {
                print("Error")
            }
            
            //            var chatUid:String = NSUUID().UUIDString
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ListTableViewCell
            
            var userTwoImageFile = PFFile(name: "profPic.png", data: UIImagePNGRepresentation(cell.cellProfilePic.image!)!)
            var allChatUsernames = Array<String>()
            allChatUsernames.append((PFUser.currentUser()?.username)!)
            allChatUsernames.append(cell.cellNameLabel.text!)
            
            var chatObject = PFObject(className: "Chats")
            chatObject["userOne"] = PFUser.currentUser()?.objectId
            chatObject["userTwo"] = otherUserObjectId
            chatObject["nameOne"] = PFUser.currentUser()!.username
            chatObject["nameTwo"] = cell.cellNameLabel.text
            chatObject["userOneProfPic"] = userOneImageFile
            chatObject["userTwoProfPic"] = userTwoImageFile
            chatObject["lastMessage"] = ""
            chatObject["allChatUsernames"] = allChatUsernames
            chatObject["lastMessageSeen"] = true
            chatObject["lastMessageFrom"] = PFUser.currentUser()!.username
            chatObject["messageUids"] = Array<String>()
            chatObject["flags"] = 0
            print("got this far")
            chatObject.saveInBackgroundWithBlock {
                (success, error) in
                if success == true {
                    print("got the chat object")
                    print(chatObject)
                    self.chatObjectToPass = chatObject
                    self.performSegueWithIdentifier("toNewChat", sender: self)
                } else {
                    //                    println(error)
                }
            }
            
        } else {
            var queryOne = PFQuery(className: "Chats")
            queryOne.whereKey("userOne", equalTo:otherUserObjectId)
            queryOne.whereKey("userTwo", equalTo:PFUser.currentUser()!.objectId!)
            var queryTwo = PFQuery(className: "Chats")
            queryTwo.whereKey("userOne", equalTo:PFUser.currentUser()!.objectId!)
            queryTwo.whereKey("userTwo", equalTo:otherUserObjectId)
            var query = PFQuery.orQueryWithSubqueries([queryOne, queryTwo])
            query.findObjectsInBackgroundWithBlock {
                (objects: [PFObject]?, error: NSError?) -> Void in
                
                if error == nil {
                    // The find succeeded.
                    print("Successfully retrieved \(objects!.count) scores.")
                    // Do something with the found objects
                    if let objects = objects {
                        if objects.count > 0 {
                            self.chatObjectToPass = objects.first
                            self.performSegueWithIdentifier("toNewChat", sender: self)
                            
                        }
                    }
                } else {
                    // Log details of the failure
                    print("Error: \(error!) \(error!.userInfo)")
                }
            }
            
        }
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath) as! ListTableViewCell
        
        cell.cellProfilePic.image = nil
        cell.backgroundColor = UIColor.whiteColor()
//        cell.greenDotFriend.hidden = true
        
        for elem in filteredObjects {
            var userString = elem["username"] as! String
            self.filteredStringObjects.append(userString)
        }
//        
//        for elem in self.filteredStringObjects {
//            if filteredStringObjects.contains(elem) {
//                cell.greenDotFriend.hidden = false
//            } else {
//                cell.greenDotFriend.hidden = true
//            }
//        }
//        
        
        
        if(searchActive){
            if filteredObjects.count > indexPath.row {
                cell.cellNameLabel.text = filteredObjects[indexPath.row]["username"] as! String
                cell.cellNameLabel.textColor = UIColor.grayColor()
                filteredObjects[indexPath.row]["profilePicture"]!.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        
                        cell.cellProfilePic.image = nil
                        
                        cell.cellProfilePic.image = UIImage(data:imageData!)
                        cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
                        cell.cellProfilePic.clipsToBounds = true
                        
                        
                        
                        
                    } else {
                        print(error)
                    }
                }
                
                
//                var cellUserGeoPoint = filteredObjects[indexPath.row]["location"] as! PFGeoPoint
//                var distance = currUserGeoPoint.distanceInMilesTo(cellUserGeoPoint)
//                cell.cellDistance.font = UIFont.systemFontOfSize(15)
//                cell.cellDistance.textColor = Constants.greenColor
//                if distance < 1 {
//                    cell.cellDistance.text = String(format: "%.0f", (distance*5280)) + " ft"
//                } else {
//                    cell.cellDistance.text = String(format: "%.0f", (distance)) + " mi"
//                }
                var theActiveClass = filteredObjects[indexPath.row]["activeClass"] as! String
                
                cell.cellActiveClass.textColor = Constants.greenColor
                
                if theActiveClass.characters.count <= 2 {
                    cell.cellActiveClass.font = UIFont.systemFontOfSize(12)
                    cell.cellActiveClass.text = "None"
                    cell.cellActiveClass.textColor = Constants.greenColor
                    
                    //tableView.deleteRowsAtIndexPaths(NSArray(object: NSIndexPath(forRow: indexPath.row, inSection: 2)) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                }
                else {
                    
                    cell.cellActiveClass.text = filteredObjects[indexPath.row]["activeClass"] as! String
                    cell.cellActiveClass.font = UIFont.systemFontOfSize(20)
                    cell.cellActiveClass.textColor = Constants.greenColor
                }


            }
            
            } else {   //if we're not searching
            cell.cellActiveClass.textColor = Constants.greenColor
            cell.cellNameLabel.text = userObjects[indexPath.row]["username"] as! String
            cell.cellNameLabel.textColor = UIColor.grayColor()
            userObjects[indexPath.row]["profilePicture"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    
                    cell.cellProfilePic.image = nil
                    
                    cell.cellProfilePic.image = UIImage(data:imageData!)
                    cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
                    cell.cellProfilePic.clipsToBounds = true
                } else {
                    print(error)
                }
            }
            
            var cellUserGeoPoint = userObjects[indexPath.row]["location"] as! PFGeoPoint
            var distance = currUserGeoPoint.distanceInMilesTo(cellUserGeoPoint)
            cell.cellDistance.font = UIFont.systemFontOfSize(15)
            cell.cellDistance.textColor = Constants.greenColor
            if distance < 1 {
                cell.cellDistance.text = String(format: "%.0f", (distance*5280)) + " ft"
            } else {
                cell.cellDistance.text = String(format: "%.0f", (distance)) + " mi"
            }
            
            var theActiveClass = userObjects[indexPath.row]["activeClass"] as! String
            
            if theActiveClass.characters.count <= 2 {
                cell.cellActiveClass.font = UIFont.systemFontOfSize(20)
                cell.cellActiveClass.text = "None"
                
                //tableView.deleteRowsAtIndexPaths(NSArray(object: NSIndexPath(forRow: indexPath.row, inSection: 2)) as! [NSIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
            else {
                
                cell.cellActiveClass.text = userObjects[indexPath.row]["activeClass"] as! String
                cell.cellActiveClass.font = UIFont.systemFontOfSize(20)
            }

        }
        
        var found = false
//        cell.greenDotFriend.hidden = true
        for friend in self.friendUsernames {
            if friend == cell.cellNameLabel.text {
                print("got inside here")
                found = true
            }
        }
        
        if found == false {
            cell.greenDotFriend.hidden = true
        } else {
            cell.greenDotFriend.hidden = false
        }
        	
        
        //ALL GOOD AFTER HERE
//        userObjects[indexPath.row]["profilePicture"].getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//            if error == nil {
//                
//                cell.cellProfilePic.image = nil
//                
//                cell.cellProfilePic.image = UIImage(data:imageData!)
//                cell.cellProfilePic.layer.cornerRadius = cell.cellProfilePic.frame.size.width/2
//                cell.cellProfilePic.clipsToBounds = true
//            } else {
//                print(error)
//            }
//        }
        
        
        return cell
    }
    
  
    var notIncluded:[String] = ["", "<your class here>"]

    
    func getUsers() {
        userObjects = Array<PFObject>()
        nameToUserDict = Dictionary<String, PFObject>()
        let query = PFQuery(className:"_User")
        query.whereKey("status", notEqualTo: false)
        
        print(PFUser.currentUser())
        query.whereKey("objectId", notEqualTo: (PFUser.currentUser()?.objectId)!)
        
        //query.whereKey("activeClass", notEqualTo: "")
        //query.whereKey("activeClass", notEqualTo: "<your class here>")
        
        query.whereKey("activeClass", notContainedIn: notIncluded)
        
        query.whereKey("location", nearGeoPoint: currUserGeoPoint, withinMiles: 100)
        if friendMode == true {
            query.whereKey("username", containedIn: self.friendUsernames)
        }
        
        
        query.findObjectsInBackgroundWithBlock {
            (objects: [PFObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) users.")
                // Do something with the found objects
                if let objects = objects! as? [PFObject] {
                    self.userObjects = objects
                    for userObject in self.userObjects {
                        self.nameToUserDict[userObject["username"] as! String] = userObject
                    }
                    //self.membersTableView.reloadData()
                    self.getUsernames()
                    self.tableView.reloadData()
                }
            } else {
                // Log details of the failure
                print("Error: \(error!) \(error!.userInfo)")
            }
        }
    }
    
    func dismissKeyboard() {
        self.searchBar.resignFirstResponder()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toNewChat" {
            var navVC = segue.destinationViewController as! UINavigationController
            var destVC = navVC.topViewController as! ChatViewController
            destVC.currChatObjects = [chatObjectToPass]
        }
    }
    
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
    

    

//
//    func getProfPics() {
//        let query = PFQuery(className:"_User")
//        do {
//            let objects = try query.findObjects()
//            for object in objects {
//                allProfPics.append(object["profilePicture"] as! PFFile)
//            }
//        } catch {
//            print("error")
//        }
//        self.tableView.reloadData()
//    }
    

    

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
    
    
    
//    func getLocation() {
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
//            if error == nil {
////                if let objects = objects as [PFObject]! {
////                    for object in objects {
////                        object["user_courses"] = updatedClasses
////                        object.saveInBackgroundWithTarget(nil, selector: nil)
//                let location = geoPoint
//                // User's location
//               
//                // Create a query for places
//                var query = PFQuery(className:"PlaceObject")
//                //Interested in locations near user.
//                query.whereKey("location", nearGeoPoint:userGeoPoint)
//                
//                let userGeoPoint = PFUser.currentUser()?.location
//                object["location"] = userGeopoint
//                object.saveInBackgroundWithTarget(nil, selector: nil)
//
//                query.limit = 10
//                // Final list of objects
//                placesObjects = query.findObjects()
//                
//                // save location to Parse
//                
//                PFUser.currentUser()!.setValue(geoPoint, forKey: "location")
//                PFUser.currentUser()?.saveInBackground()
//            }
//        }
//    }
    
    

    }

