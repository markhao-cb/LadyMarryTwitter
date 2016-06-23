//
//  Utilities.swift
//  LadyMarryTwitter
//
//  Created by Yu Qi Hao on 6/23/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import SystemConfiguration
import JCAlertView

struct Utilities {
    
    //MARK: AlertViewType
    enum AlertViewType {
        case AlertViewWithOneButton
        case AlertViewWithTwoButtons
    }
}

struct Reachability {
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}

//MARK: GCD block
func performUIUpdatesOnMain(updates: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
        updates()
    }
}


//MARK: AlertView
func showAlertViewWith(title: String, error: String, type: Utilities.AlertViewType, firstButtonTitle: String?, firstButtonHandler: (() -> Void)?, secondButtonTitle: String?, secondButtonHandler: (() -> Void)? ) {
    switch type {
    case .AlertViewWithOneButton:
        JCAlertView.showOneButtonWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler)
        break
    case .AlertViewWithTwoButtons:
        JCAlertView.showTwoButtonsWithTitle(title, message: error, buttonType: .Default, buttonTitle: firstButtonTitle, click: firstButtonHandler, buttonType: .Cancel, buttonTitle: secondButtonTitle, click: secondButtonHandler)
        break
    }
}