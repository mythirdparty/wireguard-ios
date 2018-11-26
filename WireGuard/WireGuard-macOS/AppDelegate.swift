// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var mainMenu: MainMenu?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let mainVC = MainViewController()
        let window = NSWindow(contentViewController: mainVC)
        window.delegate = self

        // Set main menu
        let mainMenu = MainMenu(applicationName: "WireGuard")
        NSApp.mainMenu = mainMenu
        self.mainMenu = mainMenu

        mainMenu.onFileNewTunnelClicked = {
            let tunnelEditVC = TunnelEditTableViewController()
            mainVC.presentAsSheet(tunnelEditVC)
        }

        // Auto-save window position and size
        window.windowController?.shouldCascadeWindows = false
        window.setFrameAutosaveName(NSWindow.FrameAutosaveName("MainWindow"))

        window.makeKeyAndOrderFront(self)
    }
}

extension AppDelegate: NSWindowDelegate {
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // TODO: Check for unsaved changes
        NSApp.terminate(self)
        return true
    }
}
