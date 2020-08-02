// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/ReplacePresentationAnimator.swift
// Description : Replace Presentation Animator
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class ReplacePresentationAnimator: NSObject, NSViewControllerPresentationAnimator {
    func animatePresentation(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = fromViewController.view.window {
            window.contentViewController = viewController
        }
    }

    func animateDismissal(of viewController: NSViewController, from fromViewController: NSViewController) {
        if let window = viewController.view.window {
            window.contentViewController = fromViewController
        }
    }
}
