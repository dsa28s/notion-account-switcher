//
//  String.swift
//  notion-account-switcher
//
//  Created by 도라도라 on 2020/08/02.
//  Copyright © 2020 Dora Lee. All rights reserved.
//

import Foundation

extension String {
    var trimEverything: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
