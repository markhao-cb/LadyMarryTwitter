//
//  TwitterClient.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/22/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import STTwitter

class TwitterClient {
    static let sharedInstance = TwitterClient()
    private init() {}
    
    private let sttwitter = STTwitterAPI(OAuthConsumerKey: Constants.ConsumerKey, consumerSecret: Constants.ConsumerSecret)
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        sttwitter.postTokenRequest({ (url, token) in
            
            self.loginWithUrlAndToken(url, token: token, hostViewController: hostViewController, completionHandlerForLogin: { (success, errorString) in
                if success {
                    completionHandlerForAuth(success: success, errorString: nil)
                }
            })
            }, oauthCallback: Constants.OAuthCallback) { (error) in
                print(error.localizedDescription)
        }
    }
    
    private func loginWithUrlAndToken(authorizationURL: NSURL?, token: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        
        let request = NSURLRequest(URL: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("LMTAuthViewController") as! LMTAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = token
        webAuthViewController.completionHandlerForView = completionHandlerForLogin
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        performUIUpdatesOnMain {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        }
    }
}