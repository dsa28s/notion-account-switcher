// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/AccountListCell.swift
// Description : Account List Cell for TableView
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class AccountListCell: NSTableCellView, LoadableView {
    var mainView: NSView?
    
    @IBOutlet weak var faviconImage: NSImageView!
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var removeLabel: NSButton!
    
    private var notionUserInfo: NotionUserInfo?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: NSRect.zero)
        
        if load(fromNibNamed: "AccountListCell") {
            initializeView()
        }
    }

    
    fileprivate func initializeView() {
        
    }
    
    func setUserInfo(notionUserInfo: NotionUserInfo) {
        self.notionUserInfo = notionUserInfo
        self.emailLabel.stringValue = self.notionUserInfo!.email
    }
    
    func setFavicon(_ image: NSImage) {
        self.faviconImage.image = image
    }
    
    func setEditMode(_ isEnabled: Bool) {
        removeLabel.isHidden = !isEnabled
    }
    
    func setCurrentUserIsSameUser(_ isSameUser: Bool) {
        if isSameUser {
            self.emailLabel.stringValue = "\(self.notionUserInfo!.email) (\(NSLocalizedString("LoggedIn", comment: "")))"
        } else {
            self.emailLabel.stringValue = self.notionUserInfo!.email
        }
    }
}
