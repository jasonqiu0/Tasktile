//
//  CalendarView.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/11/25.
//

import SwiftUI
import AppKit

struct Day: Identifiable, Hashable {
    var id = UUID()
    let number: Int
    let isPlaceholder: Bool
}

func getDays(month: Int, year: Int) -> [Day] {
    var days: [Day] = []
    let calendar = Calendar(identifier: .gregorian)
    var components = DateComponents(year: year, month: month)
    components.day = 1
    
    guard let firstDayDate = calendar.date(from: components) else { return days }
    let weekday = calendar.component(.weekday, from: firstDayDate)
    let offset = (weekday + 5) % 7
    
    for _ in 0..<offset {
        days.append(Day(number: 0, isPlaceholder: true))
    }
    
    let range = calendar.range(of: .day, in: .month, for: firstDayDate)!
    for day in range {
            days.append(Day(number: day, isPlaceholder: false))
    }
    return days
    
}

struct CalendarView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    let month: Int
    let year: Int
    @AppStorage("savedTasks") private var savedTasks: String = ""
    @State private var tasks: [Task] = []
    
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
        let days = getDays(month: month, year: year)

        VStack {
            HStack {
                Button("View Tasks") {
                    print("Button pressed: View Tasks")
                    appDelegate.openNewWindow(view: TasksWindow(), title: "Tasks")
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(appDelegate.openWindows["Tasks"]==true)

                Button("Settings") {
                    appDelegate.openNewWindow(view: SettingsWindow(), title: "Settings")
                }
                    .buttonStyle(BorderedButtonStyle())
                    .disabled(appDelegate.openWindows["Settings"]==true)
                

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "door.left.hand.open")
                }
            }

            Divider()

            HStack(spacing: 0.1) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: 26)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }

            LazyVGrid(columns: gridItems, spacing: 5) {
                ForEach(days, id: \.self) { day in
                    ZStack {
                        
                        let tasksForDay = getTasksForDay(day.number)
                        
                        RoundedRectangle(cornerRadius: 5)
                            .fill(colorForTaskCompletion(tasksForDay))
                            .fill(day.isPlaceholder ? Color.clear : Color(red: 0, green: 0.9, blue: 0.5).opacity(0.2))
                            .frame(width: 20,height: 20)
                        
                        if appDelegate.showDate {
                            if !day.isPlaceholder {
                                Text("\(day.number)")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .onAppear {
            loadTasks()
        }
    }
    private func loadTasks() {
        if let data = savedTasks.data(using: .utf8), let decoded = try? JSONDecoder().decode([Task].self, from: data) {
            tasks = decoded
        } else {
            tasks = []
        }
    }
    
    private func getTasksForDay(_ day: Int) -> [Task] {
        let calendar = Calendar.current
        return appDelegate.tasks.filter { task in
            let taskDay = calendar.component(.day, from: task.date)
            return taskDay == day || task.repeatOption == .daily || (task.repeatOption == .weekly && isSameWeekday(task.date, day))
        }
    }

    private func isSameWeekday(_ taskDate: Date, _ calendarDay: Int) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.weekday, from: taskDate) == calendar.component(.weekday, from: DateComponents(year: year, month: month, day: calendarDay).date!)
    }

    private func colorForTaskCompletion(_ tasksForDay: [Task]) -> Color {
        if tasksForDay.isEmpty { return Color.gray.opacity(0.2) }
        let completedTasks = tasksForDay.filter { $0.completed }.count
        let opacity = Double(completedTasks) / Double(tasksForDay.count)
        return Color.white.opacity(opacity)
    }
    
    
    
    
}
