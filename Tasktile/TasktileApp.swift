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

    func applicationDidFinishLaunching(_ notification: Notification) {
        popover = NSPopover()
        popover.behavior = .semitransient
        popover.contentSize = NSSize(width: 200, height: 200)
        popover.contentViewController = NSHostingController(rootView: PopoverView().environmentObject(self))

        statusBarController = StatusBarController(popover: popover)
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
            contentRect: NSRect(x: 765, y: 600, width: 300, height: 400),
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
}
