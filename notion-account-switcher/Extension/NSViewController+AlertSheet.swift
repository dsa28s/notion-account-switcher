// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Extension/NSViewController+AlertSheet.swift
// Description : Alert Sheet Extension for NSViewController
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

extension NSViewController {
    func showAlertSheet(
        alertStyle: NSAlert.Style,
        titleLocalizationKey: String,
        descriptionLocalizationKey: String,
        buttonLocalizationKeys: [String],
        responseHandler: @escaping (NSApplication.ModalResponse) -> (Void)) {
        let alertSheet = NSAlert()
        
        alertSheet.messageText = NSLocalizedString(titleLocalizationKey, comment: "")
        alertSheet.informativeText = NSLocalizedString(descriptionLocalizationKey, comment: "")
        alertSheet.alertStyle = alertStyle
        
        buttonLocalizationKeys.forEach {
            alertSheet.addButton(withTitle: NSLocalizedString($0, comment: ""))
        }
        
        alertSheet.beginSheetModal(for: self.view.window!) { (response) in
            responseHandler(response)
        }
    }
}
