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
    
    // authentication state
    var accessToken: String? = nil
    var userID: String? = nil
    
    
    static let sharedInstance = TwitterClient()
    private init() {}
    
    private lazy var sttwitter = STTwitterAPI(OAuthConsumerKey: Constants.ConsumerKey, consumerSecret: Constants.ConsumerSecret)
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        sttwitter.postTokenRequest({ (url, token) in
            
            self.loginWithUrlAndToken(url, token: token, hostViewController: hostViewController, completionHandlerForLogin: { (success, errorString, token, verifier) in
                
                if success {
                    
                    self.setOAuthTokenAndVerifier(token!, verifier: verifier!, completionHandlerForSetOauth: { (success, errorString, accessToken, userID) in
                        
                        if success {
                            
                            self.userID = userID!
                            self.accessToken = accessToken!
                            Utilities.userDefault.setValue(userID!, forKey: "UserID")
                            Utilities.userDefault.setValue(accessToken!, forKey: "AccessToken")
                            
                            completionHandlerForAuth(success: true, errorString: nil)
                            
                        } else {
                            
                            completionHandlerForAuth(success: false, errorString: errorString)
                        }
                    })
                    
                } else {
                    completionHandlerForAuth(success: false, errorString: errorString)
                }
            })
            }, oauthCallback: Constants.OAuthCallback) { (error) in
                completionHandlerForAuth(success: false, errorString: error.localizedDescription)
        }
    }
    
    private func loginWithUrlAndToken(authorizationURL: NSURL?, token: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?, oauthToken: String?, oauthVerifier: String?) -> Void) {
        
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
    
    private func setOAuthTokenAndVerifier(token: String, verifier: String, completionHandlerForSetOauth: (success: Bool, errorMessage: String?, accessToken: String?, userID: String?)-> Void) {
        sttwitter.postAccessTokenRequestWithPIN(verifier, successBlock: { (oauthToken, oauthTokenSecret, userID, screenName) in
            
            completionHandlerForSetOauth(success: true, errorMessage: nil, accessToken: oauthToken, userID: userID)
            }) { (error) in
               completionHandlerForSetOauth(success: false, errorMessage: error.localizedDescription, accessToken: nil, userID: nil)
        }
    }
}