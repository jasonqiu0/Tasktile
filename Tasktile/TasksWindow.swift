//
//  TasksWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/11/25.
//

import SwiftUI

struct TasksWindow: View {
    @AppStorage("savedTasks") private var savedTasks: String = ""  // Store tasks persistently
    @State private var tasks: [Task] = []
    @State private var newTaskTitle: String = ""
    @State private var selectedDate = Date()
    @State private var selectedRepeatOption: RepeatOption = .none

    var body: some View {
        VStack {
            List {
                ForEach(tasks.indices, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            TextField("Enter Task", text: Binding(
                                get: { tasks[index].title },
                                set: { tasks[index].title = $0; saveTasks() }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Scheduled: \(formattedDate(tasks[index].date))")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("Repeat: \(tasks[index].repeatOption.rawValue)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            deleteTask(at: index)
                        }) {
                            Image(systemName: "trash.fill")
                        }
                    }
                }
            }

            VStack {
                TextField("New Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)

                Picker("Repeats on", selection: $selectedRepeatOption) {
                    ForEach(RepeatOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())

                Button("Add Task") {
                    addTask()
                }
                .disabled(newTaskTitle.isEmpty)
            }

            Button("Close") {
                NSApp.keyWindow?.close()
            }
        }
        .frame(width: 370, height: 500)
        .onAppear {
            loadTasks()
        }
    }

    private func addTask() {
        let newTask = Task(title: newTaskTitle, date: selectedDate, repeatOption: selectedRepeatOption)
        tasks.append(newTask)
        newTaskTitle = ""
        saveTasks()
    }

    private func deleteTask(at index: Int) {
        tasks.remove(at: index)
        saveTasks()
    }

    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            savedTasks = String(data: encoded, encoding: .utf8) ?? ""
        }
    }

    private func loadTasks() {
        if let data = savedTasks.data(using: .utf8), let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            tasks = []
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
