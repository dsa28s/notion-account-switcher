// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/LoadingController.swift
// Description : Loading View Controller
// Author: Dora Lee <lee@sanghun.io>


import Cocoa
import PermissionsKit

class LoadingController: NSViewController, PermissionRequestDelegate {
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
        self.checkFullDiskAccessAndRequestPermission()
    }
    
    private func startLDBServer() {
        LDBServer.shared.startServer()
    }
    
    private func checkFullDiskAccessAndRequestPermission() {
        let permissionStatus = PermissionsKit.authorizationStatus(for: .fullDiskAccess)
        
        if permissionStatus != .authorized {
            self.progressIndicator.stopAnimation(nil)
            
            let permissionRequestView = PermissionRequestView()
            permissionRequestView.add(toView: self.view)
            permissionRequestView.delegate = self
        }
    }
    
    func onPermissionRequest() {
        PermissionsKit.requestAuthorization(for: .fullDiskAccess) { status in
            if status == .authorized {
                print("OK")
            }
        }
    }notion-account-switcher/LoadingController.swift 
}

