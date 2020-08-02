// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/AccountListController.swift
// Description : Acclout List Controller
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class AccountListController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var accountTable: NSTableView!
    @IBOutlet weak var addAccountButton: NSButton!
    @IBOutlet weak var removeAccountButton: NSButton!
    
    private var notionDatas: [NotionUserInfo] = []
    private var currentLoggedInUser: NotionUserInfo?
    private var cachedFavicons: Dictionary<String, NSImage> = Dictionary()
    
    private var isEditMode = false
    
    override func viewDidLoad() {
        titleLabel.stringValue = NSLocalizedString("LoggedInAccount", comment: "")
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        addAccountButton.changeLabel(localizedStringKey: "AddAccount")
        removeAccountButton.changeLabel(localizedStringKey: "RemoveAccount")
        
        accountTable.tableColumns.forEach {
            accountTable.removeTableColumn($0)
        }
        
        let defaultColumnTable = NSTableColumn()
        defaultColumnTable.title = "Data"
        accountTable.addTableColumn(defaultColumnTable)
        
        accountTable.headerView = nil
        accountTable.delegate = self
        accountTable.dataSource = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        notionDatas = PackageManager.getSavedNotionDatas()
        notionDatas.forEach { item in
            self.loadFavicons(email: item.email) { image in
                self.cachedFavicons[item.email] = image
                self.accountTable.reloadData()
            }
        }
        
        LDBServer.shared.getCurrentLoggedInUser { user in
            self.currentLoggedInUser = user
            self.accountTable.reloadData()
        }
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let accountCell = AccountListCell()
        accountCell.setUserInfo(notionUserInfo: notionDatas[row])
        accountCell.setEditMode(isEditMode)
        
        if let favicon = self.cachedFavicons[notionDatas[row].email] {
            accountCell.setFavicon(favicon)
        }
        
        if let currentLoggedInUser = self.currentLoggedInUser {
            if self.notionDatas[row].userId == currentLoggedInUser.userId.replacingOccurrences(of: "-", with: "") {
                accountCell.setCurrentUserIsSameUser(true)
            } else {
                accountCell.setCurrentUserIsSameUser(false)
            }
        } else {
            accountCell.setCurrentUserIsSameUser(false)
        }
        
        return accountCell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notionDatas.count
    }
    
    func changeButtonLabel(_ button: NSButton, localizedStringKey: String) {
        
    }
    
    @IBAction func removeAccountAction(_ sender: Any) {
        if !self.isEditMode {
            self.isEditMode = true
            self.addAccountButton.isEnabled = false
            self.removeAccountButton.changeLabel(localizedStringKey: "Done")
        } else {
            self.isEditMode = false
            self.addAccountButton.isEnabled = true
            self.removeAccountButton.changeLabel(localizedStringKey: "RemoveAccount")
        }

        self.accountTable.reloadData()
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
