//
//  AppDelegate.swift
//  STUnitas
//
//  Created by 양혜리 on 07/04/2019.
//  Copyright © 2019 양혜리. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow()
        let mainVC = SImageViewController()
        let navi = UINavigationController(rootViewController: mainVC)
        window?.rootViewController = navi
        window?.makeKeyAndVisible()
        return true
    }
}

