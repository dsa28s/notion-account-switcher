// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/LoadingController.swift
// Description : Package Manager for app.
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import AppKit
import tarkit

class PackageManager: NSObject {
    private class var fileManager: FileManager {
        get {
            return FileManager.default
        }
    }
    
    private class var userApplicationSupportDirectoryPath: String {
        get {
            let paths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
            return paths.first!
        }
    }
    
    private class var notionDataPath: String {
        get {
            return "\(userApplicationSupportDirectoryPath)/Notion"
        }
    }
    
    private class var appDataPath: String {
        get {
            return "\(userApplicationSupportDirectoryPath)/Notion Account Switcher"
        }
    }
    
    private class var notionDataSavePath: String {
        get {
            return "\(appDataPath)/Datas"
        }
    }
    
    private class var nasudMagicHeader: [UInt8] {
        get {
            return Array("notion-account-switcher-user-data".utf8)
        }
    }
    
    class final func isInstalledNotionApplication() -> Bool {
        let workspace = NSWorkspace.shared
        return workspace.urlForApplication(withBundleIdentifier: "notion.id") != nil
    }
    
    private class final func getNotion_NSRunningApplication() -> [NSRunningApplication] {
        return NSWorkspace.shared.runningApplications.filter({ (value: NSRunningApplication) -> Bool in return (value.bundleIdentifier == "notion.id") } )
    }
    
    class final func isRunningNotion() -> Bool {
        let runningNotionApps = getNotion_NSRunningApplication()
        return runningNotionApps.count > 0
    }
    
    class final func archiveNotionAppData(userId: String, email: String) -> Bool {
        try? fileManager.createDirectory(at: URL(fileURLWithPath: notionDataSavePath), withIntermediateDirectories: true, attributes: nil)
        
        let archivePath = "\(notionDataSavePath)/\(email)_\(userId.replacingOccurrences(of: "-", with: ""))"
        
        do {
            if fileManager.fileExists(atPath: "\(archivePath).nasud") {
                try fileManager.removeItem(atPath: "\(archivePath).nasud")
            }
            if fileManager.fileExists(atPath: "\(archivePath).tar") {
                try fileManager.removeItem(atPath: "\(archivePath).tar")
            }
            
            try DCTar.compressFile(atPath: notionDataPath, toPath: "\(archivePath).tar")
            
            var fileData = try Data(contentsOf: URL(fileURLWithPath: "\(archivePath).tar"))
            for (index, element) in nasudMagicHeader.enumerated() {
                fileData.insert(element, at: index)
            }
            
            try fileData.write(to: URL(fileURLWithPath: "\(archivePath).nasud"))
            try fileManager.removeItem(atPath: "\(archivePath).tar")
            
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    class final func getSavedNotionDatas() -> [NotionUserInfo] {
        guard let nasuds = try? fileManager.contentsOfDirectory(atPath: "\(notionDataSavePath)").filter({ (value: String) -> Bool in return (value.hasSuffix(".nasud")) }) else {
            return []
        }
        
        return nasuds.map(
            { (value: String) ->
                NotionUserInfo in return NotionUserInfo(email: String(value.split(separator: "_")[0]), userId: String(value.split(separator: "_")[1].replacingOccurrences(of: ".nasud", with: "")))
            })
    }
    
    class final func removeUserData(email: String, userId: String) {
        let archivePath = "\(notionDataSavePath)/\(email)_\(userId.replacingOccurrences(of: "-", with: ""))"
        
        if fileManager.fileExists(atPath: "\(archivePath).nasud") {
            try? fileManager.removeItem(atPath: "\(archivePath).nasud")
        }
    }
    
    class final func clearNotionApplicationData() {
        if let notion = getNotion_NSRunningApplication().first {
            notion.forceTerminate()
        }
        
        try? fileManager.removeItem(atPath: notionDataPath)
    }
}
