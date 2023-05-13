//
//  CaloriesWatchExtension.swift
//  CaloriesWatchExtension
//
//  Created by Bill Gestrich on 4/29/23.
//  Copyright © 2023 Bill Gestrich. All rights reserved.
//

import WidgetKit
import SwiftUI
import Intents
import CoreData

struct Provider: IntentTimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(calories: 0, date: Date(), lastChangeDate: Date(), configuration: ConfigurationIntent())
    }
    
    func freshPersistentManager() -> PersistenceManager {
        return PersistenceManager(appGroup: "group.org.gestrich.calorie-log")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        getEntry(configuration: configuration) { entry in
            completion(entry)
        }
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getEntry(configuration: configuration) { entry in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }

    func recommendations() -> [IntentRecommendation<ConfigurationIntent>] {
        return [
            IntentRecommendation(intent: ConfigurationIntent(), description: "CaloriesWatchExtension")
        ]
    }
    
    func getEntry(configuration: ConfigurationIntent, completion: @escaping (SimpleEntry) -> Void ) {
        let persistentManager = freshPersistentManager()
        let todayFetchRequest = PersistenceManager.foodFetchRequestForToday()
        DispatchQueue.global(qos: .default).asyncAfter(deadline: .now() + 3, execute: { //give a few seconds to sync records
            persistentManager.managedObjectContext.perform {
                let result = try! persistentManager.managedObjectContext.fetch(todayFetchRequest)
                let calories = result.reduce(0) { partialResult, food in
                    return partialResult + food.calories.intValue
                }
                for pathAndDate in persistentManager.persistentStoreFileNameAndDates() {
                    print(pathAndDate)
                }
//                printStoreContents(url: persistentManager.persistentContainer.persistentStoreDescriptions.first?.url)
                completion(SimpleEntry(calories: calories, date: Date(), lastChangeDate: persistentManager.lastWALUpdate(), configuration: configuration))
            }
        })
    }
}

struct SimpleEntry: TimelineEntry {
    let calories: Int
    let date: Date
    let lastChangeDate: Date?
    let configuration: ConfigurationIntent
}

struct CaloriesWatchExtensionEntryView : View {
    @State var entry: Provider.Entry
    let managedObjectContext: NSManagedObjectContext

    var body: some View {
        CaloriesComplicationView(entry: entry)
            .environment(
                    \.managedObjectContext,
                     managedObjectContext)
    }
    

}

@main
struct CaloriesWatchExtension: Widget {
    let kind: String = "CaloriesWatchExtension"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            CaloriesWatchExtensionEntryView(entry: entry, managedObjectContext: Provider().freshPersistentManager().managedObjectContext)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

struct CaloriesWatchExtension_Previews: PreviewProvider {
    static var previews: some View {
        CaloriesWatchExtensionEntryView(entry: SimpleEntry(calories: 0, date: Date(), lastChangeDate: Date(), configuration: ConfigurationIntent()), managedObjectContext: Provider().freshPersistentManager().managedObjectContext)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
