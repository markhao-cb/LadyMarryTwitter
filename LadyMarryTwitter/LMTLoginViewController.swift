//
//  LMTLoginViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/23/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import Canvas

class LMTLoginViewController: UIViewController {
    
    //MARK: - Properties
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet private weak var backLabel: UILabel!
    
    //MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        configAnimations()
        setupButton()
    }
    
    //MARK: - Action
    @IBAction private func loginPressed(sender: UIButton) {
        if !Reachability.isConnectedToNetwork(){
            displayError("Internet Disconnected")
            return
        }
        setUIEnabled(false)
        
        TwitterClient.sharedInstance.authenticateWithViewController(self) { (success, errorString) in
            performUIUpdatesOnMain({
                self.setUIEnabled(true)
                if success {
                    self.directToHomePage()
                } else {
                    self.displayError(errorString)
                }
            })
        }
    }
}

//MARK: - Networking Methods
extension LMTLoginViewController {
    
    private func checkSignInStatus() {
        let progressHUD = ProgressHUD(text: "Loading")
        progressHUD.show()
        view.addSubview(progressHUD)
        
        let sttwitter = Utilities.appDelegate.sttwitter
        
        sttwitter?.verifyCredentialsWithUserSuccessBlock({ (userName, userID) in
            performUIUpdatesOnMain({
                progressHUD.hide()
                self.changeTextForLabel(self.backLabel, text: "Welcome back, \(userName)!")
                UIView.animateWithDuration(0.5, animations: {
                    self.backLabel.alpha = 1
                    }, completion: { (finished) in
                        if finished {
                            delay(3.0, closure: { 
                                self.directToHomePage()
                            })
                        }
                })
            })
            }, errorBlock: { (error) in
                performUIUpdatesOnMain({
                    progressHUD.hide()
                    UIView.animateWithDuration(0.5, animations: {
                        self.loginButton.alpha = 1
                    })
                })
        })
        
    }
}


//MARK: - UI Related Methods
extension LMTLoginViewController {
    
    private func configUI() {
        loginButton.alpha = 0
        backLabel.alpha = 0
    }
    
    private func configAnimations() {
        var frame = self.logoImageView.frame
        frame.origin.y -= 200
        UIView.animateWithDuration(2, animations: {
            self.logoImageView.frame = frame
        }) { (finished) in
            if finished {
                self.checkSignInStatus()
            }
        }
    }
    
    private func setUIEnabled(enabled: Bool) {
        loginButton.enabled = enabled
        
        // adjust login button alpha
        if enabled {
            loginButton.alpha = 1.0
        } else {
            loginButton.alpha = 0.5
        }
    }
    
    private func displayError(errorString: String?) {
        if let errorString = errorString {
            showAlertViewWith("Oops", error: errorString, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
        }
    }
    
    private func setupButton() {
        loginButton.layer.cornerRadius = 5
    }
    
    private func directToHomePage() {
        let navigationController = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as! UINavigationController
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
}
