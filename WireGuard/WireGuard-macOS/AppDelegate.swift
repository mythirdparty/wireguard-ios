// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainMenu: MainMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainVC = MainViewController()
        let window = NSWindow(contentViewController: mainVC)

        // Set main menu
        let mainMenu = MainMenu(applicationName: "WireGuard")
        NSApp.mainMenu = mainMenu
        self.mainMenu = mainMenu

        // Auto-save window position and size
        window.windowController?.shouldCascadeWindows = false
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("MainWindow"))

        window.makeKeyAndOrderFront(self)
    }

}

