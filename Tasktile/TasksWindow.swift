//
//  TasksWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/11/25.
//

import SwiftUI

struct TasksWindow: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @AppStorage("savedTasks") private var savedTasks: String = ""
    @State private var newTaskTitle: String = ""
    @State private var selectedDate = Date()
    @State private var selectedRepeatOption: RepeatOption = .none

    var body: some View {
        VStack {
            List {
                ForEach(appDelegate.tasks, id: \.id) { task in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { task.completed },
                            set: { newValue in
                                if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                    appDelegate.tasks[index].completed = newValue
                                    appDelegate.saveTasks()
                                }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(CheckboxToggleStyle())

                        VStack(alignment: .leading) {
                            TextField("Enter Task", text: Binding(
                                get: { task.title },
                                set: { newValue in
                                    if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                        appDelegate.tasks[index].title = newValue
                                        appDelegate.saveTasks()
                                    }
                                }
                            ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())

                            Text("Scheduled: \(formattedDate(task.date))")
                                .font(.caption)
                                .foregroundColor(.gray)

                            Text("Repeat: \(task.repeatOption.rawValue)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }

                        Button(action: {
                            deleteTask(task)
                        }) {
                            Image(systemName: "trash.fill")
                        }
                    }
                }
                .onDelete(perform: deleteTaskFromSwipe)
            }

            VStack {
                TextField("New Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 60)

                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)

                Picker("Repeats", selection: $selectedRepeatOption) {
                    ForEach(RepeatOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 90)

                Button("Add Task") {
                    addTask()
                }
                .disabled(newTaskTitle.isEmpty)
            }

            Button("Close") {
                NSApp.keyWindow?.close()
            }
            
            Spacer()
        }
        .frame(width: 500, height: 600)
    }

    private func addTask() {
        let newTask = Task(title: newTaskTitle, date: selectedDate, repeatOption: selectedRepeatOption)
        withAnimation {
            appDelegate.tasks.append(newTask)
        }
        newTaskTitle = ""
        appDelegate.saveTasks()
    }

    private func deleteTask(_ task: Task) {
        withAnimation {
            if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                appDelegate.tasks[index].completed = false
                appDelegate.tasks.remove(at: index)
            }
        }
        appDelegate.saveTasks()
    }

    private func deleteTaskFromSwipe(at offsets: IndexSet) {
        withAnimation {
            appDelegate.tasks.remove(atOffsets: offsets)
        }
        appDelegate.saveTasks()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
