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
    
    @State private var confirmingDeletionForTask: Task? = nil
    
    @State private var taskBeingExtended: Task? = nil
    @State private var extendFromDate = Date()
    @State private var extendToDate = Date()

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
                DatePicker("View Tasks for", selection: $filterDate, displayedComponents: .date)
                    .padding(.horizontal, 20)
                
            }

            List {
                ForEach(filteredTasks(), id: \.id) { task in
                    HStack {

                        Toggle("", isOn: Binding(
                            get: {
                                let dateForCompletion = getCurrentCompletionDate()
                                return task.isCompleted(for: dateForCompletion)
                            },
                            set: { newValue in
                                if let idx = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                    let dateForCompletion = getCurrentCompletionDate()
                                    appDelegate.tasks[idx].toggleCompletion(for: dateForCompletion)
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
                                    if let idx = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                        appDelegate.tasks[idx].title = newValue
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
                        
                        if task.repeatOption == .daily || task.repeatOption == .weekly {
                            Button {
                                if taskBeingExtended?.id == task.id {
                                    taskBeingExtended = nil
                                } else {
                                    taskBeingExtended = task
                                    extendFromDate = task.date
                                    extendToDate = task.repeatUntil ?? Date().addingTimeInterval(60 * 60 * 24 * 7)
                                }
                            } label: {
                                Image(systemName: "arrow.left.arrow.right.square.fill")
                            }
                        }
                        
                        Button {
                            handleDelete(task)
                        } label: {
                            Image(systemName: "trash.fill")
                        }


                    }
                    if let t = confirmingDeletionForTask,
                       t.id == task.id,
                       taskViewOption == .allTasks,
                       task.repeatOption != .none {
                        Text("Deleting in \"All Tasks\" View Mode will delete all occurrences of this repeating task. Are you sure?")
                            .font(.footnote)
                            .padding(.vertical, 4)

                        HStack {
                            Button("Delete") {
                                deleteAllOccurrences(of: task)
                                confirmingDeletionForTask = nil
                            }
                            .foregroundColor(.red)
                            .buttonStyle(.borderedProminent)
                            .tint(.red)
                            Button("Cancel") {
                                confirmingDeletionForTask = nil
                            }
                        }
                        .listStyle(.plain)
                        .listRowSeparator(.hidden)
                    }
                    
                    if let t = taskBeingExtended, t.id == task.id {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Extend or Shorten a Repeating Task")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            /*
                            DatePicker("From:", selection: $extendFromDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                            */
                            DatePicker("Extend/Shorten to:", selection: $extendToDate, displayedComponents: .date)
                                .datePickerStyle(.compact)

                            HStack {
                                Button("Apply") {
                                    if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                        appDelegate.tasks[index].extendOrShortenTask(from: extendFromDate, to: extendToDate)
                                        appDelegate.saveTasks()
                                    }
                                    taskBeingExtended = nil
                                }
                                .buttonStyle(.borderedProminent)
                                .padding(.trailing, 5)

                                Button("Cancel") {
                                    taskBeingExtended = nil
                                }
                                .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
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
                
                if taskViewOption != .todayTasks {
                    DatePicker("Starting From", selection: $selectedDate, displayedComponents: .date)
                        .padding(.horizontal, 20)
                }
                else {

                }

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
        .onChange(of: taskViewOption) { _, newValue in
            if newValue == .todayTasks {
                selectedDate = Calendar.current.startOfDay(for: Date())
            }
        }
        .frame(width: 370, height: 500)
    }

    private func filteredTasks() -> [Task] {
        switch taskViewOption {
        case .allTasks:
            return appDelegate.tasks

        case .specificDate:
            
            let dayStart = Calendar.current.startOfDay(for: filterDate)
            return appDelegate.tasks.filter { $0.appearsOn(dayStart) }

        case .todayTasks:
            let today = Calendar.current.startOfDay(for: Date())
            return appDelegate.tasks.filter { $0.appearsOn(today) }
        }
    }
    
    private func getCurrentCompletionDate() -> Date {
        switch taskViewOption {
        case .allTasks:
            
            return Calendar.current.startOfDay(for: Date())

        case .specificDate:
            
            return Calendar.current.startOfDay(for: filterDate)

        case .todayTasks:
            
            return Calendar.current.startOfDay(for: Date())
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
        let actualRepeatUntil = repeatIndefinitely ? nil : repeatUntilDate

        let newTask = Task(
            title: newTaskTitle,
            date: selectedDate,
            repeatOption: selectedRepeatOption,
            repeatUntil: actualRepeatUntil
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
    
    private func handleDelete(_ task: Task) {
      
        if taskViewOption == .allTasks, task.repeatOption != .none {
            confirmingDeletionForTask = task
            return
        }
      
        if taskViewOption == .todayTasks, task.repeatOption != .none {
            let today = Calendar.current.startOfDay(for: Date())
            deleteSingleOccurrence(task, on: today)
            return
        }
      
        if taskViewOption == .specificDate, task.repeatOption != .none {
            let dayStart = Calendar.current.startOfDay(for: filterDate)
            deleteSingleOccurrence(task, on: dayStart)
            return
        }

      
        withAnimation {
            if let idx = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                appDelegate.tasks.remove(at: idx)
            }
        }
        appDelegate.saveTasks()
    }
    
    private func deleteAllOccurrences(of task: Task) {
        withAnimation {
            appDelegate.tasks.removeAll { $0.id == task.id }
        }
        appDelegate.saveTasks()
    }
    
    
    private func deleteSingleOccurrence(_ task: Task, on date: Date) {
        if let idx = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
            let dayKey = dayKey(for: date)
            appDelegate.tasks[idx].excludedDates.insert(dayKey)

            appDelegate.saveTasks()
        }
    }
    
    private func dayKey(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }
    
    private func applyExtension(for task: Task) {
        if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
            appDelegate.tasks[index].extendOrShortenTask(from: extendFromDate, to: extendToDate)
            appDelegate.saveTasks()
        }
        taskBeingExtended = nil
    }
    

}
