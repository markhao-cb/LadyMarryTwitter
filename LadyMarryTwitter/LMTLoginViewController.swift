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
    @IBOutlet weak var animationView: CSAnimationView!
    
    //MARK: -Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                    let tabbarController = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(tabbarController, animated: true, completion: nil)
                } else {
                    self.displayError(errorString)
                }
            })
        }
    }
    @IBAction func btnTouchDown(sender: UIButton) {
        animationView.startCanvasAnimation()
    }
}


//MARK: - UI Related Methods
extension LMTLoginViewController {
    
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
        loginButton.layer.cornerRadius = loginButton.frame.size.width / 2
    }
}
