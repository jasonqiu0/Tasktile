//
//  SettingsWindow.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/12/25.
//

import SwiftUI

struct SettingsWindow: View {
    @EnvironmentObject var appDelegate: AppDelegate
    @State private var showColorPicker = false
    
    var body: some View {
        VStack {
            
            List {
                Toggle("Show Dates on Activity Map",isOn: $appDelegate.showDate)
                    .padding(.horizontal, 20)
                
                Picker("Start Week On", selection: $appDelegate.weekStartDay) {
                    Text("Monday").tag("Monday")
                    Text("Sunday").tag("Sunday")
                }
                .padding(.horizontal, 20)
                .pickerStyle(MenuPickerStyle())
                .onChange(of: appDelegate.weekStartDay) { oldValue, newValue in
                    appDelegate.saveWeekStartDay()
                        
                }
                
                DisclosureGroup("Task Tile Color", isExpanded: $showColorPicker) {
                    ColorPicker("", selection: $appDelegate.taskColor)
                        .onChange(of: appDelegate.taskColor) { oldValue, newValue in
                            appDelegate.saveTaskColor(newValue)
                        }
                        .labelsHidden()
                }
                .padding(.horizontal, 20)
                
                Picker("Month View", selection: $appDelegate.selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 20)
                .onChange(of: appDelegate.selectedMonth) { oldValue, newValue in
                    appDelegate.saveCalendarSettings()
                }

                Picker("Year View", selection: $appDelegate.selectedYear) {
                    ForEach(2023...2027, id: \.self) { year in
                        Text(String(year))
                            .tag(year)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.horizontal, 20)
                .onChange(of: appDelegate.selectedYear) { oldValue, newValue in
                    appDelegate.saveCalendarSettings()
                }
                
                Button("Restore to Default Month & Year") {
                    appDelegate.restoreToDefaultCalendarView()
                }
                .padding()
            }
            /*
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
            */
        }
        .frame(width: 300, height: 300)
    }
}

