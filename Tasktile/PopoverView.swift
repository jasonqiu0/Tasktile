//
//  PopoverView.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import SwiftUI

struct PopoverView: View {
    @EnvironmentObject var appDelegate: AppDelegate

    var body: some View {
        VStack {
            CalendarView(month: Calendar.current.component(.month, from: Date()),
                         year: Calendar.current.component(.year, from: Date()))
            .environmentObject(appDelegate)

            Spacer()
        }
        .frame(width: 200, height: 260)
        .padding()
    }
}
