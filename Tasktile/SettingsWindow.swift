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
                
            }
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
        }
        .frame(width: 300, height: 200)
    }
}

