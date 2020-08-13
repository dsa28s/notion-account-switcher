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
    private var pushedViewController: NSViewController?

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
        
        #if !DEBUG
        if permissionStatus != .authorized {
            self.progressIndicator.stopAnimation(nil)
            
            let permissionRequestView = PermissionRequestView()
            permissionRequestView.add(toView: self.view)
            permissionRequestView.delegate = self
            
            NSApplication.shared.setActivationPolicy(.regular)
            NSApplication.shared.mainWindow?.level = .normal
            
            return
        }
        #endif
        
        if PackageManager.isAddMode() {
            self.showNotionLoginInformation()
        } else {
            if PackageManager.getSavedNotionDatas().count > 0 {
                self.checkNotionDataExist { isLoggedIn, userInfo in
                    if isLoggedIn {
                        PackageManager.archiveNotionAppData(userId: userInfo!.userId, email: userInfo!.email) { isSuccess in
                            if isSuccess {
                                self.showAccountList()
                            } else {
                                self.showErrorApplyNotionAppDataFailed()
                            }
                        }
                    } else {
                        self.showAccountList()
                    }
                }
            } else {
                self.checkNotionDataExist { isLoggedIn, userInfo in
                    if isLoggedIn {
                        PackageManager.archiveNotionAppData(userId: userInfo!.userId, email: userInfo!.email) { isSuccess in
                            if isSuccess {
                                self.showAccountList()
                            } else {
                                self.showErrorApplyNotionAppDataFailed()
                            }
                        }
                    } else {
                        self.showNotionLoginInformation()
                    }
                }
            }
        }
    }
    
    private func checkNotionDataExist(resultHandler: @escaping (Bool, NotionUserInfo?) -> Void) {
        if !LDBServer.shared.isRunning {
            self.showErrorServerLoadFailed()
        } else {
            LDBServer.shared.getCurrentLoggedInUser { userInfo in
                if let userInfo = userInfo {
                    resultHandler(true, userInfo)
                } else {
                    resultHandler(false, nil)
                }
            }
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
                    
                    PackageManager.archiveNotionAppData(userId: userInfo!.userId, email: userInfo!.email) { isSuccess in
                        if isSuccess {
                            self.showAccountList()
                        } else {
                            self.showErrorApplyNotionAppDataFailed()
                        }
                    }
                }
            }
        }
    }
    
    func showAccountList() {
        if let accountListController = storyboard?.instantiateController(withIdentifier: "AccountListController") as? AccountListController {
            self.present(accountListController, animator: ReplacePresentationAnimator())
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

