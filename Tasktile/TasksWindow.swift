//
//  TasksWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/11/25.
//

import SwiftUI

struct TasksWindow: View {
    var body: some View {
        VStack {
            
            List {
                Text("Task 1")
                Text("Task 2")
                Text("Task 3")
            }
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}
