//
//  HomeTimeLineViewController.swift
//  CFTwitterSwift
//
//  Created by Bradley Johnson on 9/16/14.
//  Copyright (c) 2014 CodeFellows. All rights reserved.
//

import UIKit
import Social
import Accounts

class HomeTimeLineViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var tweets = [Tweet]()
    var networkController = TwitterNetworkController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        
        //set our delegates
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        //register our nib for use with our tableview
        self.tableView.registerNib(UINib(nibName: "TweetCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "TweetCell")
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //fetching tweets from our networkcontroller
        self.networkController.fetchUsersHomeTimeLineWithCompletionHandler { (errorDescription, tweets) -> (Void) in
            if errorDescription != nil {
                //oh crap
            } else {
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tweets = tweets!
                    self.tableView.reloadData()
                })
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        //calling reload here because of a bug with iOS8 self sizing tableivew cells
        self.tableView.reloadData()
    }
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
         //calling reload here because of a bug with iOS8 self sizing tableivew cells
        self.tableView.reloadData()
        println("goodbye")
    }
    
    func fetchMochTweets () {
        let path = NSBundle.mainBundle().pathForResource("tweet", ofType: "json") as String?
        if path != nil {
            var error : NSError?

            let JSONData = NSData(contentsOfFile: path!)
            
            if let JSONArray = NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: &error) as? NSArray {
                //converting the raw jsonData to an Array worked, we can now parse through it
            } else {
                //converting to array didnt work, oh no :(
            }
        }
    }
    
    //our final app wont hae any segues, just pushes onto the nagivation controller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_TWEET" {
            
            let indexPath = self.tableView.indexPathForSelectedRow() as NSIndexPath?
            let tweet = self.tweets[indexPath!.row]
            let destinationViewController = segue.destinationViewController as TweetViewController
            destinationViewController.selectedTweetID = "\(tweet.id)"
            if tweet.inReplyUserIDString != nil {
                destinationViewController.selectedReplyUserID = tweet.inReplyUserIDString
            }
            destinationViewController.selectedUserID = "\(tweet.userID)"
            destinationViewController.networkController = self.networkController
        }
    }
    
    //MARK: UITableViewDataSourceDelegate
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as TweetCell
        let tweet = self.tweets[indexPath.row]
        cell.setupCell(self.tweets[indexPath.row])
        //cell.userImageView.image = nil
        if tweet.tweetAvatarImage != nil {
            cell.userImageView.image = tweet.tweetAvatarImage
        } else if tweet.imageIsDownloading == false {
        self.networkController.fetchUserImageForTweet(tweet, completionHandler: { (image) -> (Void) in
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? TweetCell
                cell?.userImageView.image = image
            })
        }
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let tweet = self.tweets[indexPath.row]
        //prep our destination view controller
        let destinationViewController = self.storyboard?.instantiateViewControllerWithIdentifier("TWEET_VC") as TweetViewController
        destinationViewController.networkController = self.networkController
        destinationViewController.selectedTweetID = "\(tweet.id)"
        destinationViewController.selectedUserID = "\(tweet.userID)"
        if tweet.inReplyUserIDString != nil {
            destinationViewController.selectedReplyUserID = tweet.inReplyUserIDString
    }
        self.navigationController?.pushViewController(destinationViewController, animated: true)
    }

    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        println(indexPath.row)
        
        
        
        for var i = indexPath.row + 3; i > indexPath.row; i-- {
            
            if i < self.tweets.count {
            let tweet = self.tweets[i]
                if tweet.tweetAvatarImage == nil && !tweet.imageIsDownloading {
            self.networkController.fetchUserImageForTweet(tweet, completionHandler: { (image) -> (Void) in
                let cell = tableView.cellForRowAtIndexPath(indexPath) as? TweetCell
                cell?.userImageView.image = image
                    })
                }
            }
        }
    }
    
}
