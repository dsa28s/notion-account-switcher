// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/PackageManager.swift
// Description : Package Manager for app.
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import AppKit

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
    
    class final func isNotionAppFocused() -> Bool {
        let runningNotionApps = getNotion_NSRunningApplication()
        return runningNotionApps.first?.isActive ?? false
    }
    
    class final func archiveNotionAppData(userId: String, email: String, completionHandler: @escaping (Bool) -> Void) {
        try? fileManager.createDirectory(at: URL(fileURLWithPath: notionDataSavePath), withIntermediateDirectories: true, attributes: nil)
        
        let archivePath = "\(notionDataSavePath)/\(email)_\(userId.replacingOccurrences(of: "-", with: ""))"
        
        do {
            if fileManager.fileExists(atPath: "\(archivePath).nasud") {
                try fileManager.removeItem(atPath: "\(archivePath).nasud")
            }
            if fileManager.fileExists(atPath: "\(archivePath).tar") {
                try fileManager.removeItem(atPath: "\(archivePath).tar")
            }
            
            let archiveTarProcess = Process()
            archiveTarProcess.launchPath = "/usr/bin/tar"
            archiveTarProcess.arguments = ["-cvf", "\(archivePath).tar", "-C", notionDataPath, "."]
            archiveTarProcess.terminationHandler = { process in
                do {
                    var fileData = try Data(contentsOf: URL(fileURLWithPath: "\(archivePath).tar"))
                    for (index, element) in nasudMagicHeader.enumerated() {
                        fileData.insert(element, at: index)
                    }
                    
                    try fileData.write(to: URL(fileURLWithPath: "\(archivePath).nasud"))
                    try fileManager.removeItem(atPath: "\(archivePath).tar")
                    
                    DispatchQueue.main.async {
                        completionHandler(true)
                    }
                } catch {
                    print(error)
                    
                    DispatchQueue.main.async {
                        completionHandler(false)
                    }
                }
            }
            
            archiveTarProcess.launch()
        } catch {
            print(error)
            
            DispatchQueue.main.async {
                completionHandler(false)
            }
        }
    }
    
    class func applyNotionData(userId: String, email: String, completionHandler: @escaping () -> Void) {
        let archivePath = "\(notionDataSavePath)/\(email)_\(userId.replacingOccurrences(of: "-", with: ""))"
        var fileData = try? Data(contentsOf: URL(fileURLWithPath: "\(archivePath).nasud"))
        
        for _ in 0..<nasudMagicHeader.count {
            fileData?.removeFirst()
        }
        
        try? fileData?.write(to: URL(fileURLWithPath: "\(archivePath).tar"))
        try? fileManager.createDirectory(at: URL(fileURLWithPath: notionDataPath), withIntermediateDirectories: true, attributes: nil)
        
        let killallProcess = Process()
        killallProcess.launchPath = "/usr/bin/tar"
        killallProcess.arguments = ["xvzf", "\(archivePath).tar", "-C", notionDataPath]
        killallProcess.terminationHandler = { process in
            try? fileManager.removeItem(atPath: "\(archivePath).tar")
            completionHandler()
        }
        killallProcess.launch()
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
    
    class final func clearNotionApplicationData(completionHandler: @escaping () -> Void) {
        let killallProcess = Process()
        killallProcess.launchPath = "/usr/bin/killall"
        killallProcess.arguments = ["Notion"]
        killallProcess.terminationHandler = { process in
            try? fileManager.removeItem(atPath: notionDataPath)
            completionHandler()
        }
        killallProcess.launch()
    }
    
    class final func setAddMode(_ isAddMode: Bool) {
        if isAddMode {
            fileManager.createFile(atPath: "\(appDataPath)/ADDLOCK", contents: nil, attributes: nil)
        } else {
            try? fileManager.removeItem(atPath: "\(appDataPath)/ADDLOCK")
        }
    }
    
    class final func isAddMode() -> Bool {
        return fileManager.fileExists(atPath: "\(appDataPath)/ADDLOCK")
    }
}
