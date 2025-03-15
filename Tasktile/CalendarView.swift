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

func getDays(month: Int, year: Int, startWeekOnMonday: Bool) -> [Day] {
    var days: [Day] = []
    let calendar = Calendar(identifier: .gregorian)
    var components = DateComponents(year: year, month: month)
    components.day = 1

    guard let firstDayDate = calendar.date(from: components) else { return days }
    let weekday = calendar.component(.weekday, from: firstDayDate)

    let offset = startWeekOnMonday ? (weekday + 5) % 7 : (weekday + 6) % 7

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
    
    @State private var selectedDate: Date? = nil
    @State private var showTaskPopup = false
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
        
        let days = getDays(
            month: appDelegate.selectedMonth,
            year: appDelegate.selectedYear,
            startWeekOnMonday: appDelegate.weekStartDay == "Monday"
        )
        
        let calendar = Calendar.current

        VStack {
            HStack {
                Button("View Tasks") {
                    print("Button pressed: View Tasks")
                    appDelegate.openNewWindow(view: TasksWindow(), title: "Tasks")
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(appDelegate.openWindows["Tasks"] == true)

                Button("Settings") {
                    appDelegate.openNewWindow(view: SettingsWindow(), title: "Settings")
                }
                .buttonStyle(BorderedButtonStyle())
                .disabled(appDelegate.openWindows["Settings"] == true)

                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                }
            }

            Divider()

            HStack(spacing: 0.1) {
                let weekDays = appDelegate.weekStartDay == "Monday"
                ? ["M", "T", "W", "T", "F", "S", "S"]
                : ["S", "M", "T", "W", "T", "F", "S"]
                
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: 26)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
            }

            LazyVGrid(columns: gridItems, spacing: 5) {
                ForEach(days, id: \.self) { day in
                    let generatedDate = calendar.date(from: DateComponents(year: year, month: month, day: day.number))
                    let isToday = generatedDate.map { Calendar.current.isDateInToday($0) } ?? false
                    
                    ZStack {
                        let tasksForDay = getTasksForDay(day.number)

                        if !day.isPlaceholder, let generatedDate = generatedDate {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(colorForTaskCompletion(tasksForDay, on: generatedDate))
                                .overlay(
                                    tasksForDay.isEmpty ? RoundedRectangle(cornerRadius: 5)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1) : nil
                                )
                                .frame(width: 20, height: 20)
                                .onTapGesture {
                                    selectedDate = generatedDate
                                    showTaskPopup = true
                                }
                            if isToday {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 5, height: 5)
                            }
                            
                            if appDelegate.showDate {
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
        .popover(isPresented: $showTaskPopup) {
            if let selectedDate = selectedDate {
                TaskPopupView(selectedDate: selectedDate, appDelegate: appDelegate)
            }
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
        guard let dayDate = Calendar.current.date(
                from: DateComponents(year: year, month: month, day: day)
            ) else {
                return []
            }
            return appDelegate.tasks.filter { $0.appearsOn(dayDate) }
    }


    private func isSameWeekday(_ taskDate: Date, _ calendarDay: Int) -> Bool {
        let calendar = Calendar.current
        guard let generatedDate = calendar.date(from: DateComponents(year: year, month: month, day: calendarDay)) else {
            print("Error: Invalid date generated for day \(calendarDay)")
            return false 
        }

        return calendar.component(.weekday, from: taskDate) == calendar.component(.weekday, from: generatedDate)
    }

    private func colorForTaskCompletion(_ tasksForDay: [Task], on date: Date) -> Color {
        if tasksForDay.isEmpty { return Color.clear }

        let completedTasks = tasksForDay.filter { $0.isCompleted(for: date) }.count
        if completedTasks == 0 { return Color.gray.opacity(0.3) }

        let opacity = Double(completedTasks) / Double(tasksForDay.count)
        
        return appDelegate.taskColor.opacity(opacity) 
    }
}
