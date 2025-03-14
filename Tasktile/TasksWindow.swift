//
//  TasksWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/11/25.
//

import SwiftUI

struct TasksWindow: View {
    @AppStorage("savedTasks") private var savedTasks: String = ""
    @State private var tasks: [String] = []
    @State private var newTask: String = ""
    var body: some View {
        VStack {
            
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    HStack {
                        TextField("Enter Task", text:Binding (
                            get: {tasks[index]},
                            set: {tasks[index] = $0; saveTasks()}
                        ))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: {
                            deleteTask(at: index)
                        }) {
                            Image(systemName: "trash.fill")
                        }
                    }
                }
            }
            
            HStack {
                TextField("New Task", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {addTask()}
                    .disabled(newTask.isEmpty)
            }
            .padding()
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
        }
        .frame(width: 300, height: 400)
        .onAppear {
            loadTasks()
        }
    }
    
    
    private func addTask() {
        tasks.append(newTask)
        newTask = ""
        saveTasks()
    }

    private func deleteTask(at index: Int) {
        tasks.remove(at: index)
        saveTasks()
    }
    
    private func saveTasks() {
        savedTasks = tasks.joined(separator: "||")
    }
    
    private func loadTasks() {
        tasks = savedTasks.isEmpty ? [] : savedTasks.components(separatedBy: "||")
    }
}
