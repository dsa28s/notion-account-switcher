// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Extension/NSButton+Label.swift
// Description : NSButton Label Extension
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

extension NSButton {
    func changeLabel(localizedStringKey: String) {
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        self.attributedTitle = NSAttributedString(string: NSLocalizedString(localizedStringKey, comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
    }
}
