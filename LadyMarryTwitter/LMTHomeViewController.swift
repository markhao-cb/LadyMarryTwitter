//
//  LMTHomeViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/22/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import TwitterKit

class LMTHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var tweets = [TWTRTweet]()

    override func viewDidLoad() {
        super.viewDidLoad()
        getTweetsByKeyword("Warriors")
        
    }
}

//MARK: - Networking Methods
extension LMTHomeViewController {
    
    private func getTweetsByKeyword(keyword: String) {
        TwitterClient.sharedInstance.postStatusesByKeyword(keyword) { (tweet, erorr) in
            if let tweet = tweet {
                if !self.tweets.contains(tweet) {
                    self.tweets.insert(tweet, atIndex: 0)
                }
                performUIUpdatesOnMain({ 
                    self.tableView.reloadData()
                })
            }
        }
    }
}

//MARK: - UITableView Delegate & DataSource
extension LMTHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TWTRTweetTableViewCell
        let tweet = tweets[indexPath.row]
        cell.configureWithTweet(tweet)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = tweets[indexPath.row]
        let height = TWTRTweetTableViewCell.heightForTweet(tweet, style: .Regular, width: CGRectGetWidth(view.bounds), showingActions: false)
        return height
    }
}

extension LMTHomeViewController {
    
}

