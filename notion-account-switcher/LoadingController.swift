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
    private var checkDataTimer: Timer?

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
            self.checkNotionDataExist { isLoggedIn, userInfo in
                if isLoggedIn {
                    
                } else {
                    self.showNotionLoginInformation()
                }
            }
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
    
    private func checkNotionDataExist(resultHandler: @escaping (Bool, NotionUserInfo?) -> Void) {
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
                            resultHandler(false, nil)
                        } else {
                            guard let data = data, error == nil else { return }

                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                                let userId = json?["notionUserId"] as! String
                                let userEmail = json?["notionUserEmail"] as! String
                                
                                let notionUser = NotionUserInfo(email: userEmail, userId: userId)
                                
                                resultHandler(true, notionUser)
                            } catch {
                                resultHandler(false, nil)
                            }
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
        
        NSWorkspace.shared.launchApplication("Notion")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            notionLoginInformationView.changeTitleLabelToNotionApp()
            
            self.waitForLoginNotion()
        }
    }
    
    func waitForLoginNotion() {
        checkDataTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(waitForLoginNotionTask), userInfo: nil, repeats: true)
    }
    
    @objc func waitForLoginNotionTask() {
        if !PackageManager.isRunningNotion() {
            checkNotionDataExist { (isLoggedIn, userInfo) in
                if isLoggedIn {
                    self.checkDataTimer?.invalidate()
                    
                    self.postNotificationCenter(titleLocalizationKey: "LoginSuccessNotificationTitle", description: "\(NSLocalizedString("LoggedIn", comment: "")) : \(userInfo!.email)")
                    PackageManager.archiveNotionAppData(userId: userInfo!.userId, email: userInfo!.email)
                }
            }
        }
    }
    
    func onPermissionRequest() {
        PermissionsKit.requestAuthorization(for: .fullDiskAccess) { status in
            if status == .authorized {
                print("Full Disk Access Permission granted.")
            }
        }
    }
}

