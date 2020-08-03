// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : Utility/LDBServer.swift
// Description : LevelDB Server for Notion Account Switcher
// Author: Dora Lee <lee@sanghun.io>

import Foundation

open class LDBServer {
    public static let shared = LDBServer()
    public static let serverEntrypoint = "http://localhost:7555"
    private init() { }
    
    private var serverProcess: Process? = nil
    
    private var serverResourcesPath: String {
        get {
            return "\(Bundle.main.builtInPlugInsPath!)/NotionAccountSwitcherLDBServer.bundle/Contents/Resources"
        }
    }
    
    private var serverBinaryPath: String {
        get {
            return "\(serverResourcesPath)/LDBServerNode"
        }
    }
    
    var isRunning: Bool {
        get {
            return serverProcess != nil && serverProcess!.isRunning
        }
    }
    
    public func startServer(completionHandler: @escaping () -> Void) {
        self.stopServer() {
            self.serverProcess = Process()
            self.serverProcess?.launchPath = self.serverBinaryPath
            self.serverProcess?.arguments = ["\(self.serverResourcesPath)/index.js"]
            self.serverProcess?.launch()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                completionHandler()
            }
        }
    }
    
    public func stopServer(completionHandler: @escaping () -> Void) {
        let killallProcess = Process()
        killallProcess.launchPath = "/usr/bin/killall"
        killallProcess.arguments = ["LDBServerNode"]
        killallProcess.terminationHandler = { process in
            completionHandler()
        }
        killallProcess.launch()
    }
    
    public func getCurrentLoggedInUser(resultHandler: @escaping (NotionUserInfo?) -> Void) {
        let request = NSMutableURLRequest(url: URL(string: "\(LDBServer.serverEntrypoint)/data/email")!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    // Notion data not found (not logged in)
                    if httpResponse.statusCode == 403 {
                        resultHandler(nil)
                    } else {
                        guard let data = data, error == nil else { return }

                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                            let userId = json?["notionUserId"] as! String
                            let userEmail = json?["notionUserEmail"] as! String
                            
                            let notionUser = NotionUserInfo(email: userEmail, userId: userId)
                            
                            resultHandler(notionUser)
                        } catch {
                            resultHandler(nil)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}

public enum LDBServerError: Error {
    case bundleExecutableError
}
