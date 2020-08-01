// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/PermissionRequestView.swift
// Description : Permission Request View
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

protocol PermissionRequestDelegate {
    func onPermissionRequest()
}

class PermissionRequestView: NSView, LoadableView {
    var mainView: NSView?
    
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var descriptionLabel: NSTextField!
    @IBOutlet weak var accessButton: NSButton!
    
    var delegate: PermissionRequestDelegate?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: NSRect.zero)
        
        if load(fromNibNamed: "PermissionRequestView") {
            initializeView()
        }
    }
    
    @IBAction func allowButtonAction(_ sender: Any) {
        delegate?.onPermissionRequest()
    }
    
    fileprivate func initializeView() {
        guard mainView != nil else { return }
        
        titleLabel.stringValue = NSLocalizedString("DiskUtilPermissionTitle", comment: "")
        descriptionLabel.stringValue = NSLocalizedString("DiskUtilPermissionDescription", comment: "")
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        accessButton.attributedTitle = NSAttributedString(string: NSLocalizedString("Allow", comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
    }
}
