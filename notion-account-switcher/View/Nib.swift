// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/Nib.swift
// Description : Extension for NibView
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

protocol LoadableView: class {
    var mainView: NSView? { get set }
    func load(fromNibNamed nibName: String) -> Bool
    func add(toView parentView: NSView)
}

extension LoadableView where Self: NSView {
    func load(fromNibNamed nibName: String) -> Bool {
        var nibObjects: NSArray?
           let nibName = NSNib.Name(stringLiteral: nibName)
        
           if Bundle.main.loadNibNamed(nibName, owner: self, topLevelObjects: &nibObjects) {
               guard let nibObjects = nibObjects else { return false }
               let viewObjects = nibObjects.filter { $0 is NSView }
        
               if viewObjects.count > 0 {
                   guard let view = viewObjects[0] as? NSView else { return false }
                   mainView = view
                   self.addSubview(mainView!)
        
                   mainView?.translatesAutoresizingMaskIntoConstraints = false
                   mainView?.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
                   mainView?.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
                   mainView?.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                   mainView?.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
                   return true
               }
           }
        
           return false
    }

    func add(toView parentView: NSView) {
        parentView.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
    }
}
