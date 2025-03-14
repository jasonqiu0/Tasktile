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

    @State private var taskViewOption: TaskViewOption = .allTasks
    @State private var filterDate = Date()

    enum TaskViewOption: String, CaseIterable {
        case allTasks = "All Tasks"
        case specificDate = "Tasks for a Specific Date"
    }

    var body: some View {
        VStack {
            Spacer()
            
            Picker("View:", selection: $taskViewOption) {
                ForEach(TaskViewOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(.horizontal, 60)

         
            if taskViewOption == .specificDate {
                DatePicker("Select Date", selection: $filterDate, displayedComponents: .date)
                    .padding(.horizontal, 20)
            }

            List {
                ForEach(filteredTasks(), id: \.id) { task in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { task.isCompleted(for: filterDate) },
                            set: { newValue in
                                if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                    appDelegate.tasks[index].toggleCompletion(for: filterDate)
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
                            Text("Repeat: \(task.repeatOption.rawValue)")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Text("Scheduled: \(formattedDate(task.date))")
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

                Picker("Repeats", selection: $selectedRepeatOption) {
                    ForEach(RepeatOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 90)
                
                DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)

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
        .frame(width: 360, height: 500)
    }

    private func filteredTasks() -> [Task] {
        if taskViewOption == .allTasks {
            return appDelegate.tasks
        } else {
            let calendar = Calendar.current
            return appDelegate.tasks.filter { task in
                let taskDay = calendar.component(.day, from: task.date)
                let filterDay = calendar.component(.day, from: filterDate)

                return taskDay == filterDay || task.repeatOption == .daily ||
                       (task.repeatOption == .weekly && isSameWeekday(task.date, filterDate))
            }
        }
    }

    private func isSameWeekday(_ taskDate: Date, _ selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: taskDate) == calendar.component(.weekday, from: selectedDate)
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
