//
//  AppDelegate.swift
//  SadAgregator
//
//  Created by Sam Yerznkyan on 11.11.2020.
//

import UIKit
import IQKeyboardManagerSwift
import YandexMobileMetrica
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
//        var systemVersion = UIDevice.current.systemVersion
//
//        if systemVersion.contains("13."){
//            IQKeyboardManager.shared.enable = true //Enabling IQKeybpard
//        }
        
        print("\(Realm.Configuration.defaultConfiguration.fileURL) REALM FILE URL")
        
        // Initializing the AppMetrica SDK.
        let configuration = YMMYandexMetricaConfiguration.init(apiKey: "e4345797-36d2-45de-8b8c-391a0c9e6559")
        YMMYandexMetrica.activate(with: configuration!)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}

