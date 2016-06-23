//
//  LMTTopicViewController.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/23/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class LMTTopicViewController: UIViewController {
    
    @IBOutlet private weak var topicTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBorderToTextField(topicTextField)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let tweetVC = segue.destinationViewController as! LMTHomeViewController
        tweetVC.keyword = topicTextField.text!
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        let topic = topicTextField.text
        if let _ = topic {
            return true
        } else {
            showAlertViewWith("Oops", error: "Topic can't be blank.", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            return false
        }
    }
}

//MARK: - UI Related Methods
extension LMTTopicViewController {
    
    private func addBorderToTextField(myTextField: UITextField) {
        let bottomLine = CALayer()
        bottomLine.frame = CGRectMake(0.0, myTextField.frame.height - 1, myTextField.frame.width, 1.0)
        bottomLine.backgroundColor = Utilities.twitterBlue.CGColor
        myTextField.borderStyle = UITextBorderStyle.None
        myTextField.layer.addSublayer(bottomLine)
        myTextField.layer.masksToBounds = true
    }
}

extension LMTTopicViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
