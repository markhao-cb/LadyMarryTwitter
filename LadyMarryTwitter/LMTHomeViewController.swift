//
//  LMTHomeViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/22/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import TwitterKit
import STTwitter

class LMTHomeViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var keyword: String?
    private var tweets = [TWTRTweet]()
    var currentTask: STTwitterRequestProtocol?

    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let keyword = keyword {
            navigationItem.title = "Topic: \(keyword)"
            getTweetsByKeyword(keyword)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let task = currentTask {
            task.cancel()
        }
    }
}

//MARK: - Networking Methods
extension LMTHomeViewController {
    
    private func getTweetsByKeyword(keyword: String) {
        currentTask = TwitterClient.sharedInstance.postStatusesByKeyword(keyword) { (tweet, erorr) in
            if let tweet = tweet {
                if !self.tweets.contains(tweet) {
                    self.tweets.insert(tweet, atIndex: 0)
                }
                performUIUpdatesOnMain({
                    let currentContentSize = self.tableView.contentSize
                    self.tableView.reloadData()
                    self.changeContentOffset(currentContentSize)
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

//MARK: - Helper Methods
extension LMTHomeViewController {
    
    private func changeContentOffset(beforeContentSize: CGSize) {
        if beforeContentSize.height > view.frame.height {
            let afterContentSize = tableView.contentSize
            let afterContentOffset = tableView.contentOffset
            let newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height)
            tableView.contentOffset = newContentOffset
        }
    }
}

