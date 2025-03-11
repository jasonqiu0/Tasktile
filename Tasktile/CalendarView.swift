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

struct CalendarView: View {
    let month: Int
    let year: Int
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    CalendarView()
}
