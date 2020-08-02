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
    
    override func viewDidLoad() {
        titleLabel.stringValue = NSLocalizedString("LoggedInAccount", comment: "")
        
        let pstyle = NSMutableParagraphStyle()
        pstyle.alignment = .center
        
        addAccountButton.attributedTitle = NSAttributedString(string: NSLocalizedString("AddAccount", comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
        removeAccountButton.attributedTitle = NSAttributedString(string: NSLocalizedString("RemoveAccount", comment: ""), attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white, NSAttributedString.Key.paragraphStyle : pstyle ])
        
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
        accountTable.reloadData()
        
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
        accountCell.setEditMode(false)
        
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
}
