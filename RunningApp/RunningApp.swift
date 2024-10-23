//
//  RunningApp.swift
//  我的跑步我做主
//
//  Created by Jake Ma on 9/6/24.
//
import SwiftUI

@main
struct RunningApp: App {
    let persistenceController = CoreDataManager.shared
    
    init() {
        ValueTransformer.setValueTransformer(StringArrayTransformer(), forName: NSValueTransformerName("StringArrayTransformer"))
        CoreDataManager.shared.initializeDefaultPlansIfNeeded()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
