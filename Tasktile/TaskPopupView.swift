//
//  TaskPopupView.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/15/25.
//

import SwiftUI

struct TaskPopupView: View {
    let selectedDate: Date
    @ObservedObject var appDelegate: AppDelegate

    var tasksForDay: [Task] {
        return appDelegate.tasks.filter { task in
            task.appearsOn(selectedDate)
        }
    }

    var body: some View {
        VStack {
            Text("Tasks for \(formattedDate(selectedDate))")
                .font(.headline)

            List {
                ForEach(tasksForDay, id: \.id) { task in
                    HStack {
                        Toggle("", isOn: Binding(
                            get: { task.isCompleted(for: selectedDate) },
                            set: { newValue in
                                if let index = appDelegate.tasks.firstIndex(where: { $0.id == task.id }) {
                                    appDelegate.tasks[index].toggleCompletion(for: selectedDate)
                                    appDelegate.saveTasks()
                                }
                            }
                        ))
                        .labelsHidden()
                        .toggleStyle(CheckboxToggleStyle())

                        Text(task.title)
                    }
                }
            }
            .frame(width: 200, height: 250)
        }
        .padding()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
