//
//  SettingsWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/12/25.
//

import SwiftUI

struct SettingsWindow: View {
    @EnvironmentObject var appDelegate: AppDelegate
    var body: some View {
        VStack {
            
            List {
                Toggle("Show Dates on Activity Map",isOn: $appDelegate.showDate)
                
                Picker("Start Week On", selection: $appDelegate.weekStartDay) {
                    Text("Monday").tag("Monday")
                    Text("Sunday").tag("Sunday")
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: appDelegate.weekStartDay) { oldValue, newValue in
                    appDelegate.saveWeekStartDay()
                }
                
            }
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
        }
        .frame(width: 300, height: 250)
    }
}

