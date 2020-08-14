// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : AppDelegate.swift
// Description : App Entrypoint
// Author: Dora Lee <lee@sanghun.io>

import Cocoa
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSObject.startUpLogin()
        SUUpdater.shared()?.automaticallyChecksForUpdates = true
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        return .terminateCancel
    }
    
    func applicationWillUnhide(_ notification: Notification) {
        NSApplication.shared.setActivationPolicy(.regular)
        self.openFirst()
    }
    
    func openFirst() {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: nil)
        let loadingController = mainStoryboard.instantiateController(withIdentifier: "MainWindowController") as! NASWindowController
        
        DispatchQueue.main.async {
            loadingController.showWindow(self)
        }
    }
    
    @IBAction func checkUpdateButtonClicked(_ menu: NSMenu) {
        SUUpdater.shared()?.checkForUpdates(self)
    }
}

