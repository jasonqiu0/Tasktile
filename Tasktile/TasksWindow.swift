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
    
    @State private var repeatUntilDate: Date = Date().addingTimeInterval(60*60*24*7)
    @State private var repeatIndefinitely: Bool = true


    enum TaskViewOption: String, CaseIterable {
        case allTasks = "All Tasks"
        case specificDate = "Tasks for a Specific Date"
        case todayTasks = "Today's Tasks"
    }

    var body: some View {
        VStack {
            Spacer()
            
            Picker("View:", selection: $taskViewOption) {
                Label("All Tasks", systemImage: "eye").tag(TaskViewOption.allTasks)
                Label("Tasks for a Specific Date", systemImage: "wrench.and.screwdriver").tag(TaskViewOption.specificDate)
                Label("Today's Tasks", systemImage: "wrench.and.screwdriver").tag(TaskViewOption.todayTasks)
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
                        if taskViewOption != .allTasks {
                            Toggle("", isOn: Binding(
                                get: { task.isCompleted(for: getCurrentFilterDate()) },
                                set: { newValue in
                                    if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                        appDelegate.tasks[index].toggleCompletion(for: getCurrentFilterDate())
                                        appDelegate.saveTasks()
                                    }
                                }
                            ))
                            .labelsHidden()
                            .toggleStyle(CheckboxToggleStyle())
                        }

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
                    Text("Only on This Day").tag(RepeatOption.none)
                    Text("Daily").tag(RepeatOption.daily)
                    Text("Weekly").tag(RepeatOption.weekly)
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 90)
                
                
                if selectedRepeatOption == .daily || selectedRepeatOption == .weekly {
                    Toggle("Repeat Indefinitely", isOn: $repeatIndefinitely)
                        .padding(.horizontal, 20)
                }
                
                DatePicker("Starting From", selection: $selectedDate, displayedComponents: .date)

                if selectedRepeatOption != .none && !repeatIndefinitely {
                    DatePicker("Repeat Until", selection: $repeatUntilDate, displayedComponents: .date)
                        .padding(.horizontal, 20)
                }

                Button("Add Task") {
                    addTask()
                }
                .disabled(newTaskTitle.isEmpty)
            }
            /*
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            */
            Spacer()
        }
        .frame(width: 370, height: 500)
    }

    private func filteredTasks() -> [Task] {
        let currentDate = getCurrentDate()

        switch taskViewOption {
        case .allTasks:
            return appDelegate.tasks
        case .specificDate:
            return filterTasksByDate(filterDate)
        case .todayTasks:
            return filterTasksByDate(currentDate)
        }
    }

    private func getCurrentDate() -> Date {
        return Calendar.current.startOfDay(for: Date())
    }

    private func filterTasksByDate(_ date: Date) -> [Task] {
        let calendar = Calendar.current
        return appDelegate.tasks.filter { task in
            let taskDay = calendar.component(.day, from: task.date)
            let filterDay = calendar.component(.day, from: date)

            return taskDay == filterDay || task.repeatOption == .daily ||
                   (task.repeatOption == .weekly && isSameWeekday(task.date, date))
        }
    }

    private func isSameWeekday(_ taskDate: Date, _ selectedDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: taskDate) == calendar.component(.weekday, from: selectedDate)
    }

    private func getCurrentFilterDate() -> Date {
        return taskViewOption == .todayTasks ? getCurrentDate() : filterDate
    }

    private func addTask() {
        let newTask = Task(
            title: newTaskTitle,
            date: selectedDate,
            repeatOption: selectedRepeatOption,
            repeatUntil: repeatIndefinitely ? nil : repeatUntilDate
        )

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
