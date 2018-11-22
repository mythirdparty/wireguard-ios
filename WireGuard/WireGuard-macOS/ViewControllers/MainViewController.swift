// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

class MainViewController: NSSplitViewController {

    init() {
        let masterVC = TunnelsListTableViewController()
        let masterSVI = NSSplitViewItem(contentListWithViewController: masterVC)

        let detailVC = BlankViewController()
        let detailSVI = NSSplitViewItem(viewController: detailVC)

        super.init(nibName: nil, bundle: nil)

        self.title = "WireGuard"

        // When resizing the window, the detail view should resize along with the window
        detailSVI.holdingPriority = .defaultLow
        masterSVI.holdingPriority = .defaultHigh

        self.addSplitViewItem(masterSVI)
        self.addSplitViewItem(detailSVI)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BlankViewController: NSViewController {
    override func loadView() {
        let view = NSView()
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            view.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
            ])
        self.view = view
    }
}
