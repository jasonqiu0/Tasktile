//
//  TaskModel.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/14/25.
//

import Foundation

struct Task: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var date: Date
    var repeatOption: RepeatOption
    var repeatUntil: Date? = nil  //
    var completedDates: [String: Bool] = [:]

    mutating func toggleCompletion(for date: Date) {
        let dateString = formattedDate(date)
        if let completed = completedDates[dateString] {
            completedDates[dateString] = !completed
        } else {
            completedDates[dateString] = true
        }
    }

    func shouldRepeat(on date: Date) -> Bool {
        guard repeatOption != .none else { return false }
        if let repeatUntil = repeatUntil, date > repeatUntil { return false }
        return true
    }
    
    func isCompleted(for date: Date) -> Bool {
        return completedDates[formattedDate(date)] ?? false
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

enum RepeatOption: String, Codable, CaseIterable {
    case none = "Only this date"
    case daily = "Daily"
    case weekly = "Weekly"
    case specificDate = "Specific Date"
}

