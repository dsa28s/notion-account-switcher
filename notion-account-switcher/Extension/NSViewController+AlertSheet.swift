//
//  NSViewController+AlertSheet.swift
//  notion-account-switcher
//
//  Created by 도라도라 on 2020/08/02.
//  Copyright © 2020 Dora Lee. All rights reserved.
//

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
