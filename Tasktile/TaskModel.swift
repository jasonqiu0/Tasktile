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
    var repeatUntil: Date? = nil  
    var completedDates: [String: Bool] = [:]
    
    var excludedDates: Set<String> = []
    
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
        if date < self.date {
                return false
            }

            if let repeatUntil = repeatUntil, date > repeatUntil {
                return false
            }

            return true
    }
    
    func isCompleted(for date: Date) -> Bool {
            let key = dayKey(for: date)
            return completedDates[key] ?? false
        }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func appearsOn(_ date: Date) -> Bool {
        
        if excludedDates.contains(dayKey(for: date)) {
            return false
        }
        
        if repeatOption == .none {
            return Calendar.current.isDate(self.date, inSameDayAs: date)
        }

        if date < Calendar.current.startOfDay(for: self.date) {
            return false
        }

        if let until = repeatUntil, date > until {
            return false
        }

        switch repeatOption {
        case .none:

            return false

        case .daily:

            return true

        case .weekly:

            let cal = Calendar.current
            let dayOfWeekTask = cal.component(.weekday, from: self.date)
            let dayOfWeekDate = cal.component(.weekday, from: date)
            return dayOfWeekTask == dayOfWeekDate

        case .specificDate:

            return Calendar.current.isDate(self.date, inSameDayAs: date)
        }
    }
    
    private func dayKey(for date: Date) -> String {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd"
            return fmt.string(from: date)
        }
    
}

enum RepeatOption: String, Codable, CaseIterable {
    case none = "Only this date"
    case daily = "Daily"
    case weekly = "Weekly"
    case specificDate = "Specific Date"
}
