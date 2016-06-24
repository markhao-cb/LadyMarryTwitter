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
import UPStackMenu

class LMTHomeViewController: UIViewController {
    
    //MARK: Properties
    var keyword: String?
    @IBOutlet private weak var tableView: UITableView!
    private lazy var allTweets = [TWTRTweet]()
    private lazy var textTweets = [TWTRTweet]()
    private lazy var mediaTweets = [TWTRTweet]()
    private var currentTask: STTwitterRequestProtocol?
    private var progressHUD : ProgressHUD?
    private var isStreaming: Bool = true
    private lazy var contentView: UIView = UIView(frame: CGRectMake(0, 0, 30, 30))
    private var stack: UPStackMenu?
    private var tableViewDataSource: TableViewDataSource = .All
    private enum TableViewDataSource {
        case All
        case TextOnly
        case Media
    }
    
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let keyword = keyword {
            navigationItem.title = "Topic: \(keyword)"
            progressHUD = ProgressHUD(text: "Fetching...")
            getTweetsByKeyword(keyword)
            delay(10, closure: {
                self.progressHUD!.hide()
            })
        }
        
        setupMenuView()
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        if let task = currentTask {
            task.cancel()
        }
    }
    
    //MARK: Actions
    
    @IBAction func stopOrStartStreaming(sender: UIBarButtonItem) {
        if isStreaming {
            currentTask?.cancel()
            let button = UIBarButtonItem(barButtonSystemItem: .Play, target: self, action: #selector(stopOrStartStreaming))
            navigationItem.rightBarButtonItem = button
            isStreaming = false
        } else {
            getTweetsByKeyword(keyword!)
            isStreaming = true
            let button = UIBarButtonItem(barButtonSystemItem: .Pause, target: self, action: #selector(stopOrStartStreaming))
            navigationItem.rightBarButtonItem = button
        }
    }
}

//MARK: - Networking Methods
extension LMTHomeViewController {
    
    private func getTweetsByKeyword(keyword: String) {
        
        view.addSubview(progressHUD!)
        progressHUD!.show()
        
        currentTask = TwitterClient.sharedInstance.postStatusesByKeyword(keyword) { (tweet, type, erorr) in
            if let tweet = tweet {
                if !self.allTweets.contains(tweet) {
                    self.allTweets.insert(tweet, atIndex: 0)
                    if let type = type {
                        if type == TwitterClient.TweetType.Media {
                            self.mediaTweets.insert(tweet, atIndex: 0)
                        } else {
                            self.textTweets.insert(tweet, atIndex: 0)
                        }
                    }
                }
                performUIUpdatesOnMain({
                    let currentContentSize = self.tableView.contentSize
                    self.tableView.reloadData()
                    if currentContentSize.height > self.view.frame.height {
                        self.progressHUD!.hide()
                        self.changeContentOffset(currentContentSize)
                    }
                })
            }
        }
    }
}

//MARK: - UITableView Delegate & DataSource
extension LMTHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableViewDataSource {
        case .All:
            return allTweets.count
        case .TextOnly:
            return textTweets.count
        case .Media:
            return mediaTweets.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TWTRTweetTableViewCell
        let tweet = getTweetFromIndexpath(indexPath.row)
        cell.configureWithTweet(tweet)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let tweet = getTweetFromIndexpath(indexPath.row)
        let height = TWTRTweetTableViewCell.heightForTweet(tweet, style: .Compact, width: CGRectGetWidth(view.bounds), showingActions: false)
        return height
    }
}

//MARK: - UI Related Method
extension LMTHomeViewController {
    private func setupMenuView() {
        
        configContentView()
        stack = UPStackMenu(contentView: contentView)
        if let stack = stack {
            stack.frame = CGRectMake(10, view.frame.height - stack.frame.height - 10, stack.frame.width, stack.frame.height)
            stack.delegate = self
            let squareItem = UPStackMenuItem.init(image: UIImage(named: "square"), highlightedImage: nil, title: "All Tweets")
            let circleItem = UPStackMenuItem.init(image: UIImage(named: "circle"), highlightedImage: nil, title: "Tweets with Text Only")
            let triangleItem = UPStackMenuItem.init(image: UIImage(named: "triangle"), highlightedImage: nil, title: "Tweets with Photo/Video")
            
            let items = [squareItem, circleItem, triangleItem]
            for item in items {
                item.setTitleColor(UIColor.whiteColor())
                item.labelPosition = UPStackMenuItemLabelPosition_right
            }
            stack.animationType = UPStackMenuAnimationType_progressive
            stack.stackPosition = UPStackMenuStackPosition_up
            stack.closeAnimationDuration = 0.5
            stack.openAnimationDuration = 0.5
            
            stack.addItems(items)
            stack.backgroundColor = Utilities.backgroundColor
            view.addSubview(stack)
            
            setStackIconColsed(true)
        }
        
    }
    
    private func configContentView() {
        contentView.backgroundColor = Utilities.twitterBlue
        let imageView = UIImageView(image: UIImage(named: "cross"))
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = CGRectInset(contentView.frame, 10, 10)
        contentView.addSubview(imageView)
    }
    
    private func setStackIconColsed(closed: Bool) {
        let icon = contentView.subviews[0]
        let angle = closed ? 0 : (M_PI * (135) / 180.0)
        UIView.animateWithDuration(0.3) {
            icon.layer.setAffineTransform(CGAffineTransformRotate(CGAffineTransformIdentity, CGFloat(angle)))
        }
    }
}

//MARK: - Helper Methods
extension LMTHomeViewController {
    
    private func changeContentOffset(beforeContentSize: CGSize) {
        let afterContentSize = tableView.contentSize
        let afterContentOffset = tableView.contentOffset
        let newContentOffset = CGPointMake(afterContentOffset.x, afterContentOffset.y + afterContentSize.height - beforeContentSize.height)
        tableView.contentOffset = newContentOffset
    }
    
    private func getTweetFromIndexpath(index: Int) -> TWTRTweet {
        let tweet: TWTRTweet?
        switch tableViewDataSource {
        case .All:
            tweet = allTweets[index]
            break
        case .TextOnly:
            tweet = textTweets[index]
            break
        case .Media:
            tweet = mediaTweets[index]
        }
        return tweet!
    }
}

//MARK: - UPStackMenuDelegate Methods
extension LMTHomeViewController: UPStackMenuDelegate {
    
    func stackMenuWillOpen(menu: UPStackMenu!) {
        if contentView.subviews.count == 0 {
            return
        }
        
        setStackIconColsed(false)
    }
    
    func stackMenuWillClose(menu: UPStackMenu!) {
        if contentView.subviews.count == 0 {
            return
        }
        
        setStackIconColsed(true)
    }
    
    func stackMenu(menu: UPStackMenu!, didTouchItem item: UPStackMenuItem!, atIndex index: UInt) {
        switch index {
        case 0: /* All Tweets */
            tableViewDataSource = .All
            break
            
        case 1: /* Tweets with Text Only */
            tableViewDataSource = .TextOnly
            break
            
        case 2: /* Tweets with Photo/Video */
            tableViewDataSource = .Media
            break
        default:
            break
        }
        tableView.reloadData()
        stack?.closeStack()
    }
}
