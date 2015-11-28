//
//  AppDelegate.swift
//  swiftclock
//
//  Created by Jose Alcalá-Correa on 28/11/15.
//  Copyright © 2015 gskbyte. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
//
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        if let launchOptions = launchOptions,
//            notification = launchOptions[UIApplicationLaunchOptionsLocalNotificationKey] as! UILocalNotification? {
//                displayAlarmNotification(notification)
//        }
//
//        return true
//    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        displayAlarmNotification(notification)
    }

    func displayAlarmNotification(notification: UILocalNotification) {
        print("alarm!")
    }
}

