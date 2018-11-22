// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainVC = MainViewController()
        let window = NSWindow(contentViewController: mainVC)

        // Auto-save window position and size
        window.windowController?.shouldCascadeWindows = false
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("MainWindow"))

        window.makeKeyAndOrderFront(self)
    }

}

