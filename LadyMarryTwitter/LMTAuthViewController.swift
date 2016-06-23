//
//  LMTAuthViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/23/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class LMTAuthViewController: UIViewController {
    
    // MARK: Properties
    
    var urlRequest: NSURLRequest? = nil
    var requestToken: String? = nil
    var completionHandlerForView: ((success: Bool, errorString: String?, oauthToken: String?, oauthVerifier: String?) -> Void)? = nil
    
    // MARK: Outlets
    
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        
        navigationItem.title = "LadyMarry Twitter Auth"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(cancelAuth))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let urlRequest = urlRequest {
            webView.loadRequest(urlRequest)
        }
    }
    
    // MARK: Cancel Auth Flow
    
    func cancelAuth() {
        dismissViewControllerAnimated(true, completion: {
            self.completionHandlerForView!(success: false, errorString: "Sign in Canceled.", oauthToken: nil, oauthVerifier: nil)
        })
    }
}

// MARK: - LMTAuthViewController: UIWebViewDelegate

extension LMTAuthViewController: UIWebViewDelegate {
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        let urlString = webView.request!.URL!.absoluteString
        let urlParts = urlString.componentsSeparatedByString("?")
        let host = urlParts.first
        let parameters = urlParts.last
        let oauthToken = parameters?.componentsSeparatedByString("&").first?.componentsSeparatedByString("=").last
        let oauthVerifier = parameters?.componentsSeparatedByString("&").last?.componentsSeparatedByString("=").last
        if host == TwitterClient.Constants.OAuthCallback {
            dismissViewControllerAnimated(true) {
                self.completionHandlerForView!(success: true, errorString: nil, oauthToken: oauthToken, oauthVerifier: oauthVerifier)
            }
        }
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if !Reachability.isConnectedToNetwork() {
            showAlertViewWith("Oops", error: "Internet Disconnected", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            return false
        }
        return true
    }
}
