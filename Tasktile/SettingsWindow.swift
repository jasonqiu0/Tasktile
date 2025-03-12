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
                Toggle("Show date",isOn: $appDelegate.showDate)
                Text("Setting2")
            }
            
            Button("Close") {
                NSApp.keyWindow?.close()
            }
            .padding()
        }
        .frame(width: 300, height: 400)
    }
}

