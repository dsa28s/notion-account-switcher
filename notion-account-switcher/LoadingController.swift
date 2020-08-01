// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/LoadingController.swift
// Description : Loading View Controller
// Author: Dora Lee <lee@sanghun.io>


import Foundation
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
            showAlertSheet(alertStyle: .critical,
                           titleLocalizationKey: "NotionAppNotInstalledErrorTitle",
                           descriptionLocalizationKey: "NotionAppNotInstalledErrorDescription",
                           buttonLocalizationKeys: ["OK"]) { response in
                NSApp.terminate(nil)
            }
        }
        
        self.startLDBServer {
            self.checkFullDiskAccessAndRequestPermission()
        }
    }
    
    private func startLDBServer(completionHandler: @escaping () -> (Void)) {
        LDBServer.shared.startServer(completionHandler: completionHandler)
    }
    
    private func checkFullDiskAccessAndRequestPermission() {
        let permissionStatus = PermissionsKit.authorizationStatus(for: .fullDiskAccess)
        
        #if DEBUG
            self.checkNotionDataExist()
        #else
            if permissionStatus != .authorized {
                self.progressIndicator.stopAnimation(nil)
                
                let permissionRequestView = PermissionRequestView()
                permissionRequestView.add(toView: self.view)
                permissionRequestView.delegate = self
            } else {
                self.checkNotionDataExist()
            }
        #endif
    }
    
    private func checkNotionDataExist() {
        if !LDBServer.shared.isRunning {
            showAlertSheet(alertStyle: .critical,
                           titleLocalizationKey: "ServerNotRunningTitle",
                           descriptionLocalizationKey: "ServerNotRunningDescription",
                           buttonLocalizationKeys: ["OK"]) { response in
                NSApp.terminate(nil)
            }
        } else {
            let request = NSMutableURLRequest(url: URL(string: "\(LDBServer.serverEntrypoint)/data/email")!)
            request.httpMethod = "GET"
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse {
                    DispatchQueue.main.async {
                        // Notion data not found (not logged in)
                        if httpResponse.statusCode == 403 {
                            self.showNotionLoginInformation()
                        } else {
                            
                        }
                    }
                }
            }
            
            task.resume()
        }
    }
    
    private func showNotionLoginInformation() {
        self.progressIndicator.stopAnimation(nil)
        
        let notionLoginInformationView = LoginNotionLoadingView()
        notionLoginInformationView.add(toView: self.view)
    }
    
    func onPermissionRequest() {
        PermissionsKit.requestAuthorization(for: .fullDiskAccess) { status in
            if status == .authorized {
                print("Full Disk Access Permission granted.")
            }
        }
    }
}

