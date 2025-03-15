//
//  TasktileApp.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import SwiftUI

@main
struct TasktileApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            CommandGroup(replacing: .appInfo) { }
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var statusBarController: StatusBarController?
    var popover: NSPopover!
    var windows: [NSWindow] = []
    
    @Published var showDate: Bool = false
    @Published var openWindows: [String: Bool] = ["Tasks": false, "Settings": false]
    @Published var tasks: [Task] = []
    
    @AppStorage("savedTasks") private var savedTasks: String = ""
    
    
    @Published var weekStartDay: String = "Monday"
    @AppStorage("weekStartDay") private var storedWeekStartDay: String = "Monday"
    
    @AppStorage("taskColorHex") private var taskColorHex: String = "#00FF00"
    @Published var taskColor: Color = Color.green
    

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentSize = NSSize(width: 200, height: 200)
        popover.contentViewController = NSHostingController(rootView: PopoverView().environmentObject(self))

        statusBarController = StatusBarController(popover: popover)
        
        loadTasks()
        
        weekStartDay = storedWeekStartDay
        
        taskColor = Color(hex: taskColorHex)
        
    }

    func openNewWindow<Content: View>(view: Content, title: String) {
        print("Opening new window: \(title)")
        guard openWindows[title] == false else {
                    print("\(title) window is already open.")
                    return
                }

                print("Opening new window: \(title)")
                openWindows[title] = true

        let window = NSWindow(
            contentRect: NSRect(x: 700, y: 600, width: 300, height: 400),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentView = NSHostingView(rootView: view.environmentObject(self))
        window.title = title
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.makeKeyAndOrderFront(nil)

        windows.append(window)

        NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: nil) { [weak self] _ in
            self?.openWindows[title] = false
        }
    }
    
    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            savedTasks = String(data: encoded, encoding: .utf8) ?? ""
        }
        objectWillChange.send()
    }

    func loadTasks() {
            if let data = savedTasks.data(using: .utf8), let decoded = try? JSONDecoder().decode([Task].self, from: data) {
                tasks = decoded
            }
        }
    
    func saveWeekStartDay() {
        storedWeekStartDay = weekStartDay
        objectWillChange.send()
    }
    
    func saveTaskColor(_ color: Color) {
        taskColorHex = color.toHex() ?? "#00FF00"
        taskColor = color
        objectWillChange.send()
    }
    
}

extension Color {
    func toHex() -> String? {
        guard let components = NSColor(self).cgColor.components, components.count >= 3 else { return nil }
        let r = Int(components[0] * 255)
        let g = Int(components[1] * 255)
        let b = Int(components[2] * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.currentIndex = hex.index(after: hex.startIndex)
        
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        let red = Double((rgbValue >> 16) & 0xFF) / 255.0
        let green = Double((rgbValue >> 8) & 0xFF) / 255.0
        let blue = Double(rgbValue & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

