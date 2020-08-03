// Copyright (c) 2020 Dora Lee
//
// Project : Notion Account Switcher for macOS
// File Name : View Controllers/AccountListController.swift
// Description : Acclout List Controller
// Author: Dora Lee <lee@sanghun.io>

import Foundation
import Cocoa

class AccountListController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSTouchBarDelegate, AccountListCellDelegate {
    @IBOutlet weak var titleLabel: NSTextField!
    @IBOutlet weak var accountTable: NSTableView!
    @IBOutlet weak var addAccountButton: NSButton!
    @IBOutlet weak var removeAccountButton: NSButton!
    @IBOutlet weak var loadingIndicator: NSProgressIndicator!
    
    private var notionDatas: [NotionUserInfo] = []
    private var currentLoggedInUser: NotionUserInfo?
    private var currentLoggedInUserIdx = -1
    private var cachedFavicons: Dictionary<String, NSImage> = Dictionary()
    
    private let touchBarControlStrip = NSCustomTouchBarItem.Identifier("io.sanghun.notion.account.switcher.controlStrip")
    private var stripTouchBarItem: NSCustomTouchBarItem?
    
    private var isEditMode = false
    private var isNotionFocused = false
    
    override func viewDidLoad() {
        PackageManager.setAddMode(false)
        
        titleLabel.stringValue = NSLocalizedString("LoggedInAccount", comment: "")
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        loadingIndicator.controlSize = .regular
        
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
        accountTable.doubleAction = #selector(self.tableDoubleClicked)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        load()
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            self.setupControlStripPresence()
        }
    }
    
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.delegate = self
        
        var identifiers: [NSTouchBarItem.Identifier] = []
        self.notionDatas.forEach {
            identifiers.append(NSTouchBarItem.Identifier("touchBar_\($0.userId.replacingOccurrences(of: "-", with: ""))"))
        }
        touchBar.defaultItemIdentifiers = identifiers
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        let touchbarUserId = identifier.rawValue.split(separator: "_")[1]
        let notionUserInfo = self.notionDatas.filter({ (value: NotionUserInfo) -> Bool in return (value.userId.replacingOccurrences(of: "-", with: "") == touchbarUserId) }).first
        
        let notionData = notionUserInfo
        let customViewItem = NSCustomTouchBarItem(identifier: identifier)
        let button = NSButton(title: notionData?.email ?? "", target: self, action: nil)
        let favicon = cachedFavicons[notionData?.email ?? ""]
        favicon?.size = NSSize(width: 24.0, height: 24.0)
        button.image = favicon
        button.imagePosition = .imageLeft
        
        button.action = #selector(self.touchBarButtonClicked(sender:))
        
        customViewItem.view = button
        
        return customViewItem
    }

    private func load() {
        currentLoggedInUserIdx = -1
        notionDatas = PackageManager.getSavedNotionDatas()
        
        if notionDatas.count == 0 {
            DispatchQueue.main.async {
                if let loadingController = self.storyboard?.instantiateController(withIdentifier: "LoadingController") as? LoadingController {
                    self.present(loadingController, animator: ReplacePresentationAnimator())
                }
            }
        }
        
        cachedFavicons = Dictionary()
        notionDatas.forEach { item in
            self.loadFavicons(email: item.email) { image in
                self.cachedFavicons[item.email] = image
                self.accountTable.reloadData()
                self.touchBar = nil
            }
        }
        
        LDBServer.shared.getCurrentLoggedInUser { user in
            self.currentLoggedInUser = user
            self.accountTable.reloadData()
            self.touchBar = nil
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
                currentLoggedInUserIdx = row
                accountCell.setCurrentUserIsSameUser(true)
            } else {
                accountCell.setCurrentUserIsSameUser(false)
            }
        } else {
            accountCell.setCurrentUserIsSameUser(false)
        }
        
        accountCell.delegate = self
        
        return accountCell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return notionDatas.count
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
    
    @IBAction func addAccountAction(_ sender: Any) {
        PackageManager.clearNotionApplicationData {
            PackageManager.setAddMode(true)
            
            DispatchQueue.main.async {
                if let loadingController = self.storyboard?.instantiateController(withIdentifier: "LoadingController") as? LoadingController {
                    self.present(loadingController, animator: ReplacePresentationAnimator())
                }
            }
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
    
    func removeButtonClicked(isCurrentUser: Bool, notionUserInfo: NotionUserInfo) {
        let descriptionKey = isCurrentUser ? "RemoveAccountCurrentUserDescription" : "RemoveAccountDescription"
        
        self.showAlertSheet(alertStyle: .warning, titleLocalizationKey: "RemoveAccountTitle", descriptionLocalizationKey: descriptionKey, buttonLocalizationKeys: ["Cancel", "RemoveAccount"]) { response in
            
            if response == .alertSecondButtonReturn {
                PackageManager.removeUserData(email: notionUserInfo.email, userId: notionUserInfo.userId.replacingOccurrences(of: "-", with: ""))
                
                if isCurrentUser {
                    PackageManager.clearNotionApplicationData {
                        self.load()
                    }
                } else {
                    self.load()
                }
            }
        }
    }
    
    @objc func tableDoubleClicked(sender: NSTableView) {
        let idx = sender.clickedRow
        openNotion(notionUserInfo: notionDatas[idx])
    }
    
    func openNotion(notionUserInfo: NotionUserInfo) {
        self.loadingIndicator.startAnimation(nil)
        
        if currentLoggedInUser?.email == notionUserInfo.email {
            NSWorkspace.shared.launchApplication("Notion")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.loadingIndicator.stopAnimation(nil)
            }
        } else {
            PackageManager.clearNotionApplicationData {
                PackageManager.applyNotionData(userId: notionUserInfo.userId.replacingOccurrences(of: "-", with: ""), email: notionUserInfo.email) {
                    NSWorkspace.shared.launchApplication("Notion")

                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        self.loadingIndicator.stopAnimation(nil)
                        self.load()
                    }
                }
            }
        }
    }
    
    @objc func touchBarButtonClicked(sender: NSButton) {
        let email = sender.title
        
        if let userInfo = notionDatas.filter({ (value: NotionUserInfo) -> Bool in return (value.email == email) }).first {
            self.openNotion(notionUserInfo: userInfo)
        }
    }
    
    func setupControlStripPresence() {
        if PackageManager.isNotionAppFocused() {
            if !isNotionFocused {
                isNotionFocused = true
                DFRSystemModalShowsCloseBoxWhenFrontMost(false)
                self.stripTouchBarItem = NSCustomTouchBarItem(identifier: self.touchBarControlStrip)
                let notionIcon = NSImage(named: "Notion")
                notionIcon!.size = NSSize(width: 20.0, height: 20.0)
                self.stripTouchBarItem?.view = NSButton(image: notionIcon!, target: self, action: #selector(presentTouchBar))
                NSTouchBarItem.addSystemTrayItem(self.stripTouchBarItem)
                DFRElementSetControlStripPresenceForIdentifier(self.touchBarControlStrip, true)
            }
        } else {
            if isNotionFocused {
                isNotionFocused = false
                NSTouchBarItem.removeSystemTrayItem(self.stripTouchBarItem!)
                self.stripTouchBarItem = nil
            }
        }
    }
    
    @objc func presentTouchBar() {
        presentSystemModal(makeTouchBar()!, systemTrayItemIdentifier: NSCustomTouchBarItem.Identifier("io.sanghun.notion.account.switcher.controlStrip"))
    }
}
