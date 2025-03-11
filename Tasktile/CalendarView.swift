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
    let month: Int
    let year: Int
    
    var body: some View {
        let gridItems = Array(repeating: GridItem(.flexible()), count: 7)
        let days = getDays(month: month, year: year)
        
        HStack(spacing: 0.1) {
            ForEach(["M", "T", "W", "T", "F", "S", "S"], id: \.self) {day in
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
                        .fill(day.isPlaceholder ? Color.clear : Color.blue.opacity(0.1))
                        .frame(width: 20,height: 20)
                        //.border(Color.gray, width: 0.5)
                    
                    if !day.isPlaceholder {
                        //Text("\(day.number)")
                            //.foregroundColor(.primary)
                    }
                }
            }
            
        }
        .padding()
    }
    
}
