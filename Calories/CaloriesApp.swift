//
//  CaloriesApp.swift
//  Calories
//
//  Created by Bill Gestrich on 4/28/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import SwiftUI

@main
struct Calories_App: App {
    
    @Environment(\.scenePhase) var scenePhase
    let persistenceManager = PersistenceManager(appGroup: nil)
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(
                    \.managedObjectContext,
                     persistenceManager.managedObjectContext)
                .environmentObject(Settings())
                .environmentObject(persistenceManager)
        }.onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                persistenceManager.updateStartOfTodayIfNecessary()
            }
        }
    }
}
