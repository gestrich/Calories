//
//  AppDelegate.swift
//  CaloriesWatchApp
//
//  Created by Bill Gestrich on 5/6/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import WatchKit

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        print("Your code here")
        NotificationCenter.default.addObserver(self, selector: #selector(self.storeRemoteChangeEvent), name: Notification.Name.NSPersistentStoreRemoteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.storeRemoteCoordinatorChangedEvent), name: Notification.Name.NSPersistentStoreCoordinatorStoresDidChange, object: nil)

    }
    
    @objc func storeRemoteChangeEvent() {
        print("remote change complete")
    }
    
    @objc func storeRemoteCoordinatorChangedEvent() {
        print("store coordinator change complete")
    }
    
    

    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any]) async -> WKBackgroundFetchResult {
        print("Notification received")
        return .noData
    }
//    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (WKBackgroundFetchResult) -> Void) {
//        print("Notification received")
//    }
}
