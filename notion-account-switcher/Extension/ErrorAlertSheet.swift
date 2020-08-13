// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Extension/ErrorAlertSheet.swift
// Description : Error Alert Sheet Extension for LoadingController, AccountListController
// Author: Dora Lee <lee@sanghun.io>

import Foundation

protocol NASErrorAlertSheetOpenable {
    func showErrorServerLoadFailed()
    func showErrorApplyNotionAppDataFailed()
}

extension NASErrorAlertSheetOpenable where Self: NSViewController {
    func showErrorServerLoadFailed() {
        self.showAlertSheet(alertStyle: .critical,
                       titleLocalizationKey: "ServerNotRunningTitle",
                       descriptionLocalizationKey: "RegisterGithubIssuePleaseDescription",
                       buttonLocalizationKeys: ["OK"]) { response in
            exit(-1)
        }
    }
    
    func showErrorApplyNotionAppDataFailed() {
        self.showAlertSheet(alertStyle: .critical,
                       titleLocalizationKey: "NotionAppDataArchiveErrorTitle",
                       descriptionLocalizationKey: "RegisterGithubIssuePleaseDescription",
                       buttonLocalizationKeys: ["OK"]) { response in
            exit(-1)
        }
    }
}

extension LoadingController: NASErrorAlertSheetOpenable {}
extension AccountListController: NASErrorAlertSheetOpenable {}
