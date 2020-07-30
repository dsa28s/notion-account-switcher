// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/PermissionRequestView.swift
// Description : Permission Request View
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class PermissionRequestView: NSView, LoadableView {
    var mainView: NSView?
    
    @IBOutlet weak var titleLabel: NSTextField?
    @IBOutlet weak var descriptionLabel: NSTextField?
    @IBOutlet weak var accessButton: NSButton?
    
    init() {
        super.init(frame: NSRect.zero)
        
        if load(fromNibNamed: "PermissionRequestView") {
            
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
