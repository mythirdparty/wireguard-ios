// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

class MainMenu: NSMenu {

    let applicationName: String

    var onAppAboutClicked: (() -> Void)?

    var onFileNewTunnelClicked: (() -> Void)?
    var onFileImportTunnelsClicked: (() -> Void)?
    var onFileExportAllTunnelsClicked: (() -> Void)?

    init(applicationName: String) {
        self.applicationName = applicationName
        super.init(title: "MainMenu")
        addSubmenu(title: "Application", menu: createApplicationMenu())
        addSubmenu(title: "File", menu: createFileMenu())
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func addSubmenu(title: String, menu: NSMenu) {
        let menuItem = self.addItem(withTitle: title, action: nil, keyEquivalent: "")
        self.setSubmenu(menu, for: menuItem)
    }

    private func createApplicationMenu() -> NSMenu {
        let menu = NSMenu(title: "Application")

        let aboutMenuItem = menu.addItem(withTitle: "About \(applicationName)",
            action: #selector(appAboutClicked), keyEquivalent: "")
        aboutMenuItem.target = self
        menu.addItem(NSMenuItem.separator())

        let hideMenuItem = menu.addItem(withTitle: "Hide \(applicationName)",
            action: #selector(NSApplication.hide), keyEquivalent: "h")
        hideMenuItem.keyEquivalentModifierMask = [.command]
        hideMenuItem.target = NSApp

        let hideOthersMenuItem = menu.addItem(withTitle: "Hide Others",
            action: #selector(NSApplication.hideOtherApplications), keyEquivalent: "h")
        hideOthersMenuItem.keyEquivalentModifierMask = [.command, .option]
        hideOthersMenuItem.target = NSApp

        let showAllMenuItem = menu.addItem(withTitle: "Show all",
            action: #selector(NSApplication.unhideAllApplications), keyEquivalent: "")
        showAllMenuItem.target = NSApp
        menu.addItem(NSMenuItem.separator())

        let quitMenuItem = menu.addItem(withTitle: "Quit \(applicationName)",
            action: #selector(NSApplication.terminate), keyEquivalent: "q")
        quitMenuItem.keyEquivalentModifierMask = [.command]
        quitMenuItem.target = NSApp

        return menu
    }

    @objc func appAboutClicked() {
        self.onAppAboutClicked?()
    }

    private func createFileMenu() -> NSMenu {
        let menu = NSMenu(title: "File")

        let newTunnelMenuItem = menu.addItem(withTitle: "New tunnel",
            action: #selector(fileNewTunnelClicked), keyEquivalent: "n")
        newTunnelMenuItem.keyEquivalentModifierMask = [.command]
        newTunnelMenuItem.target = self

        let importTunnelsMenuItem = menu.addItem(withTitle: "Import tunnels",
            action: #selector(fileImportTunnelsClicked), keyEquivalent: "")
        importTunnelsMenuItem.target = self

        menu.addItem(NSMenuItem.separator())

        let exportTunnelsMenuItem = menu.addItem(withTitle: "Export all tunnels",
            action: #selector(fileExportAllTunnelsClicked), keyEquivalent: "")
        exportTunnelsMenuItem.target = self

        return menu
    }

    @objc func fileNewTunnelClicked() {
        self.onFileNewTunnelClicked?()
    }

    @objc func fileImportTunnelsClicked() {
        self.onFileImportTunnelsClicked?()
    }

    @objc func fileExportAllTunnelsClicked() {
        self.onFileExportAllTunnelsClicked?()
    }
}
