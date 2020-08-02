// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/AccountListController.swift
// Description : Acclout List Controller
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class AccountListController: NSViewController {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var accountTable: NSTableView!
    @IBOutlet weak var addAccountButton: NSButton!
    @IBOutlet weak var removeAccountButton: NSButton!
    
    override func viewDidLoad() {
        titleLabel.stringValue = NSLocalizedString("LoggedInAccount", comment: "")
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        addAccountButton.attributedTitle = NSAttributedString(string: NSLocalizedString("AddAccount", comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
        removeAccountButton.attributedTitle = NSAttributedString(string: NSLocalizedString("RemoveAccount", comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        
    }
}
