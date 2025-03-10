//
//  StatusBarController.swift
//  Tasktile
//
//  Created by Jason Qiu on 3/10/25.
//

import AppKit

class StatusBarController {
    private var statusBar: NSStatusBar
    private(set) var statusItem: NSStatusItem
    private(set) var popover: NSPopover
    
    init(popover: NSPopover) {
        self.popover = popover

        statusBar = NSStatusBar.system
    
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {

            button.image = NSImage(systemSymbolName: "calendar", accessibilityDescription: "Calendar")
   
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    

    @objc func togglePopover() {
        if popover.isShown {
            popover.performClose(nil)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .maxY)
        }
    }
}
