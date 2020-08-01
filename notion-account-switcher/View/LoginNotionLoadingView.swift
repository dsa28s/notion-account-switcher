// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/LoginNotionLoadingView.swift
// Description : Login Notion Information View
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class LoginNotionLoadingView: NSView, LoadableView {
    var mainView: NSView?
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: NSRect.zero)
        
        if load(fromNibNamed: "LoginNotionLoadingView") {
            initializeView()
        }
    }
    
    fileprivate func initializeView() {
        titleLabel.stringValue = NSLocalizedString("PleaseNotionLoginTitle", comment: "")
        descriptionLabel.stringValue = NSLocalizedString("PleaseNotionLoginDescription", comment: "")
        
        loadingIndicator.controlSize = .regular
        loadingIndicator.startAnimation(nil)
    }
}
