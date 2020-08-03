// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/SupportNSTouchBar.swift
// Description : Private API Helper for NSTouchBar
// Author: Dora Lee <lee@sanghun.io>

func presentSystemModal(_ touchBar: NSTouchBar!, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.presentSystemModalTouchBar(touchBar, systemTrayItemIdentifier: identifier)
    } else {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, systemTrayItemIdentifier: identifier)
    }
}

func presentSystemModal(_ touchBar: NSTouchBar!, placement: Int64, systemTrayItemIdentifier identifier: NSTouchBarItem.Identifier!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.presentSystemModalTouchBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
    } else {
        NSTouchBar.presentSystemModalFunctionBar(touchBar, placement: placement, systemTrayItemIdentifier: identifier)
    }
}

func minimizeSystemModal(_ touchBar: NSTouchBar!) {
    if #available(OSX 10.14, *) {
        NSTouchBar.minimizeSystemModalTouchBar(touchBar)
    } else {
        NSTouchBar.minimizeSystemModalFunctionBar(touchBar)
    }
}
