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
    var completed: Bool = false
}

enum RepeatOption: String, Codable, CaseIterable {
    case none = "Only this date"
    case daily = "Daily"
    case weekly = "Weekly"
    case specificDate = "Specific Date"
}

