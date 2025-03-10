//
//  TasktileApp.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import SwiftUI

@main
struct TasktileApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
