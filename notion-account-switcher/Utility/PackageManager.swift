// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/LoadingController.swift
// Description : Package Manager for app.
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import AppKit

class PackageManager: NSObject {
    class final func isInstalledNotionApplication() -> Bool {
        let workspace = NSWorkspace.shared
        return workspace.urlForApplication(withBundleIdentifier: "notion.id") != nil
    }
}
