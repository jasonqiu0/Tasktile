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
    case none = "Only This Day"
    case daily = "Repeats Daily"
    case weekly = "Repeats Weekly"
    case specificDate = "Specific Date"
}

