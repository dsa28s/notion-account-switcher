// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : NotionAccountSwitcherLDBServer/LDBServer.swift
// Description : LevelDB Server for Notion Account Switcher
// Author: Dora Lee <lee@sanghun.io>

import Foundation

open class LDBServer {
    public static let shared = LDBServer()
    private init() {}
    
    private var serverProcess: Process? = nil
    
    private var serverBinaryPath: String {
        get {
            return "\(Bundle.main.builtInPlugInsPath!)/NotionAccountSwitcherLDBServer.bundle/Contents/Resources/NotionAccountSwitcherLDBServer"
        }
    }
    
    private var isRunning: Bool {
        get {
            return serverProcess != nil && serverProcess!.isRunning
        }
    }
    
    public func startServer() throws {
        print(self.serverBinaryPath)
        self.serverProcess = Process()
        self.serverProcess?.launchPath = self.serverBinaryPath
        self.serverProcess?.launch()
    }
}

public enum LDBServerError: Error {
    case bundleExecutableError
}
