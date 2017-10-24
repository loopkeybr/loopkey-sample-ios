//
//  AppDelegate.swift
//  LKBLECommSampleApp
//
//  Created by Daniel Sandoval on 23/10/16.
//  Copyright © 2016 Loop CE. All rights reserved.
//

import UIKit
import LKBLECommunication

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication)
    {
    }

    func applicationDidEnterBackground(_ application: UIApplication)
    {
        LKBLEInteractor.sharedInstance().stopScanning()
    }

    func applicationWillEnterForeground(_ application: UIApplication)
    {
        LKBLEInteractor.sharedInstance().startScanning()
    }

    func applicationDidBecomeActive(_ application: UIApplication)
    {
    }

    func applicationWillTerminate(_ application: UIApplication)
    {
    }
}
