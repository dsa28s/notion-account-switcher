// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View/AccountListCell.swift
// Description : Account List Cell for TableView
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class AccountListCell: NSTableCellView, LoadableView {
    var mainView: NSView?
    
    @IBOutlet weak var faviconImage: NSImageView!
    @IBOutlet weak var emailLabel: NSTextField!
    @IBOutlet weak var removeLabel: NSButton!
    
    private var notionUserInfo: NotionUserInfo?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    init() {
        super.init(frame: NSRect.zero)
        
        if load(fromNibNamed: "AccountListCell") {
            initializeView()
        }
    }
    
    fileprivate func initializeView() {
        
    }
    
    func setUserInfo(notionUserInfo: NotionUserInfo) {
        self.notionUserInfo = notionUserInfo
        self.emailLabel.stringValue = self.notionUserInfo!.email
        
        self.loadFavicons(email: self.notionUserInfo!.email) { image in
            self.faviconImage.image = image
        }
    }
    
    func setEditMode(_ isEnabled: Bool) {
        removeLabel.isHidden = !isEnabled
    }
    
    func setCurrentUserIsSameUser(_ isSameUser: Bool) {
        if isSameUser {
            self.emailLabel.stringValue = "\(self.notionUserInfo!.email) (\(NSLocalizedString("LoggedIn", comment: "")))"
        } else {
            self.emailLabel.stringValue = self.notionUserInfo!.email
        }
    }
    
    private func loadFavicons(email: String, completionHandler: @escaping (NSImage) -> Void) {
        let domain = email.split(separator: "@")[1]
        
        if domain.hasSuffix("appleid.com") {
            completionHandler(NSImage(named: "Apple")!)
            return
        } else if domain.hasSuffix("gmail.com") {
            completionHandler(NSImage(named: "Google")!)
            return
        }
        
        let request = NSMutableURLRequest(url: URL(string: "http://favicongrabber.com/api/grab/\(domain)")!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    // If custom domain using, but maybe using gsuite because notion only support gmail!
                    if httpResponse.statusCode == 400 {
                        completionHandler(NSImage(named: "Google")!)
                    } else {
                        guard let data = data, error == nil else { return }

                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                            let icons = json?["icons"] as? Array<Dictionary<String, String>>
                            
                            guard let icon = icons?.filter({ (value: Dictionary<String, String>) -> Bool in return (value["type"] == "image/x-icon") }).first else {
                                completionHandler(NSImage(named: "Google")!)
                                return
                            }
                            
                            completionHandler(NSImage(byReferencing: URL(string: icon["src"] as! String)!))
                        } catch {
                            completionHandler(NSImage(named: "Google")!)
                        }
                    }
                }
            }
        }
        
        task.resume()
    }
}
