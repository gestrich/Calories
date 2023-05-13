//
//  CaloriesWatchApp.swift
//  CaloriesWatchApp
//
//  Created by Bill Gestrich on 4/24/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import SwiftUI

@main
struct CaloriesWatchApp: App {
    
    @ObservedObject private var connectivityManager = WatchConnectivityManager.shared
    @WKApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceManager = PersistenceManager(appGroup: "group.org.gestrich.calorie-log")
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                        \.managedObjectContext,
                         persistenceManager.managedObjectContext)
                .environmentObject(persistenceManager)
        }
    }
}
