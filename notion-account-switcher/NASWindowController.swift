// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/NASWindowController.swift
// Description : Global Window Controller
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class NASWindowController: NSWindowController {
    override func windowDidLoad() {
        window?.isMovableByWindowBackground = true
        window?.titlebarAppearsTransparent = true
        window?.center()
        window?.styleMask.remove(NSWindow.StyleMask.resizable)
        window?.level = .floating
        
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}
