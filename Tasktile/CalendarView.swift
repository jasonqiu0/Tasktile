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
    //let showDate: Bool = false
    
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

                Button("Settings") {
                    appDelegate.openNewWindow(view: SettingsWindow(), title: "Settings")
                }
                    .buttonStyle(BorderedButtonStyle())
                

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
                        RoundedRectangle(cornerRadius: 5)
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
    }
}
