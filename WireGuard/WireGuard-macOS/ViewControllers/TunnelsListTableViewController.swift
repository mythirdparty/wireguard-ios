// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

class TunnelsListTableViewController: NSViewController {

    override func loadView() {
        let tableView = NSTableView()
        let scrollView = NSScrollView()
        let contentView = NSClipView()
        contentView.documentView = tableView
        scrollView.contentView = contentView
        NSLayoutConstraint.activate([
            scrollView.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
            ])
        self.view = scrollView
    }
}
