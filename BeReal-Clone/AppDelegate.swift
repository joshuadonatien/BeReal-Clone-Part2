//
//  AppDelegate.swift
//  BeReal-Clone
//
//  Created by Joshua  Donatien on 2/10/26.
//
//
//  AppDelegate.swift
//  BeReal-Clone
//
//  Application delegate - handles app lifecycle and Parse initialization
//

import UIKit
import Parse

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupParse()
        return true
    }

    // MARK: - Parse Setup

    private func setupParse() {
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = Constants.Parse.applicationId
            $0.clientKey = Constants.Parse.clientKey
            $0.server = Constants.Parse.serverURL
        }
        Parse.initialize(with: parseConfig)
        print("Parse initialized")
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
