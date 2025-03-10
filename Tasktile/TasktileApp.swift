//
//  TasktileApp.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import SwiftUI

@main
struct TasktileApp: App {

    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
