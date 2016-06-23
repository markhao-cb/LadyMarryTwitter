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
        setupStreaming()
        
    }
}

//MARK: - Networking Methods
extension LMTHomeViewController {
    
    private func setupStreaming() {
        TwitterClient.sharedInstance.getStatusesSample()
    }
}

