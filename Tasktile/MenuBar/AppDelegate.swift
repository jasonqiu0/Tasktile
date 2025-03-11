//
//  AppDelegate.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {

        popover = NSPopover()
        popover.behavior = .transient
        popover.contentSize = NSSize(width: 200, height: 200)

        popover.contentViewController = NSHostingController(rootView: PopoverView())
        

        statusBarController = StatusBarController(popover: popover)
    }
}
