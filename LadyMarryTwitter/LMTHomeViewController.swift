//
//  LMTHomeViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/22/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class LMTHomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func loginPressed(sender: UIButton) {
        TwitterClient.sharedInstance.authenticateWithViewController(self) { (success, errorString) in
            if success {
                
            } else {
                print(errorString)
            }
        }
    }
}

