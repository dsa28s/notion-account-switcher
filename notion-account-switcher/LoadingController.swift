// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/LoadingController.swift
// Description : Loading View Controller
// Author: Dora Lee <lee@sanghun.io>


import Cocoa

class LoadingController: NSViewController {
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    override func viewDidAppear() {
        super.viewDidLoad()

        self.progressIndicator.controlSize = .regular
        self.progressIndicator.startAnimation(nil)
        
        checkNotionAppInstalled()
    }

    private func checkNotionAppInstalled() {
        if !PackageManager.isInstalledNotionApplication() {
            let noInstalledErrorSheet = NSAlert()
            
            noInstalledErrorSheet.messageText = NSLocalizedString("NotionAppNotInstalledErrorTitle", comment: "")
            noInstalledErrorSheet.informativeText = NSLocalizedString("NotionAppNotInstalledErrorDescription", comment: "")
            noInstalledErrorSheet.alertStyle = .critical
            noInstalledErrorSheet.addButton(withTitle: NSLocalizedString("OK", comment: ""))
            
            noInstalledErrorSheet.beginSheetModal(for: self.view.window!) { (response) in
                NSApp.terminate(nil)
            }
        }
        
        self.startLDBServer()
    }
    
    private func startLDBServer() {
        // try? LDBServer.shared.startServer()
        
        let testView = PermissionRequestView()
        testView.add(toView: self.view)
    }
}

