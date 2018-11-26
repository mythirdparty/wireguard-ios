// SPDX-License-Identifier: MIT
// Copyright © 2018 WireGuard LLC. All Rights Reserved.

import Cocoa

class TunnelEditTableViewController: NSViewController {

    override func loadView() {
        let titleLabel = NSTextField(labelWithString: "Create a new tunnel")

        let tableView = TableView()
        tableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Column")))
        tableView.headerView = nil

        let scrollView = NSScrollView()
        scrollView.wantsLayer = true
        let contentView = NSClipView()
        contentView.documentView = tableView
        scrollView.contentView = contentView

        tableView.dataSource = self
        tableView.delegate = self

        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelClicked))
        let createButton = NSButton(title: "Create", target: self, action: #selector(createClicked))
        let bottomBar = NSStackView()
        bottomBar.setViews([cancelButton, createButton], in: .trailing)
        bottomBar.orientation = .horizontal

        let containerView = NSStackView(views: [titleLabel, scrollView, bottomBar])
        containerView.orientation = .vertical
        containerView.edgeInsets = NSEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)
        containerView.spacing = 10

        NSLayoutConstraint.activate([
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 480),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 480)
            ])

        self.view = containerView
    }

    @objc func createClicked() {
        print("createClicked")
    }

    @objc func cancelClicked() {
        NSApp.mainWindow?.contentViewController?.dismiss(self)
    }
}

class TableView: NSTableView {
    func dequeueReusableSectionHeader(withIdentifier idString: String, for indexPath: IndexPath) -> SectionHeader {
        let id = NSUserInterfaceItemIdentifier(idString)
        if let sectionHeaderView = self.makeView(withIdentifier: id, owner: self) as? SectionHeader {
            return sectionHeaderView
        }
        let sectionHeader = SectionHeader()
        sectionHeader.identifier = id
        return sectionHeader
    }

    func dequeueReusableCell(withIdentifier idString: String, for indexPath: IndexPath) -> TunnelEditTableViewKeyValueCell {
        let id = NSUserInterfaceItemIdentifier(idString)
        if let cellView = self.makeView(withIdentifier: id, owner: self) as? TunnelEditTableViewKeyValueCell {
            return cellView
        }
        let cell = TunnelEditTableViewKeyValueCell()
        cell.identifier = id
        return cell
    }
}

extension TunnelEditTableViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 6
    }
}

extension TunnelEditTableViewController: NSTableViewDelegate {
    func semanticIndexPath(forRow row: Int) -> IndexPath {
        let indexPath: IndexPath
        if (row == 0) {
            indexPath = IndexPath(index: 0)
        } else if (row < 3) {
            indexPath = IndexPath(indexes: [0, row - 1])
        } else if (row == 3) {
            indexPath = IndexPath(index: 1)
        } else if (row < 6) {
            indexPath = IndexPath(indexes: [1, row - 3])
        } else {
            fatalError()
        }
        return indexPath
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let indexPath = semanticIndexPath(forRow: row)
        if let tableView = tableView as? TableView {
            if (indexPath.count == 1) { // Section header
                let sectionHeader = tableView.dequeueReusableSectionHeader(withIdentifier: "SectionHeader", for: indexPath)
                let section = indexPath.first!
                sectionHeader.text = (section == 0) ? "Interface" : "Peer"
                return sectionHeader
            } else if (indexPath.count == 2) { // Row
                let cell = tableView.dequeueReusableCell(withIdentifier: "TunnelEditTableViewKeyValueCell", for: indexPath)
                cell.key = "Name"
                cell.placeholderText = "Required"
                cell.value = ""
                return cell
            }
        }

        return nil
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        let indexPath = semanticIndexPath(forRow: row)
        if (indexPath.count == 1) { // Section header
            return 32
        } else if (indexPath.count == 2) { // Row
            return 24
        } else {
            return 0
        }
    }
}

class TunnelEditTableViewKeyValueCell: NSView {
    static let id: String = "TunnelEditTableViewKeyValueCell"
    var key: String {
        get { return keyLabel.stringValue }
        set(value) {keyLabel.stringValue = value }
    }
    var value: String {
        get { return valueTextField.stringValue }
        set(value) { valueTextField.stringValue = value }
    }
    var placeholderText: String {
        get { return valueTextField.placeholderString ?? "" }
        set(value) { valueTextField.placeholderString = value }
    }
    var isValueValid: Bool = true {
        didSet {
            // TODO: Need to support dark mode
        }
    }

    var onValueChanged: ((String) -> Void)?
    var onValueBeingEdited: ((String) -> Void)?

    let keyLabel: NSTextField
    let valueTextField: NSTextField

    private var textFieldValueOnBeginEditing: String = ""

    override init(frame: NSRect) {
        keyLabel = NSTextField(labelWithString: "")
        valueTextField = NSTextField(string: "")
        super.init(frame: frame)
        self.addSubview(keyLabel)
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        keyLabel.alignment = .right
        NSLayoutConstraint.activate([
            keyLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            keyLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 16),
            keyLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2)
            ])
        self.addSubview(valueTextField)
        valueTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            valueTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            valueTextField.leftAnchor.constraint(equalTo: keyLabel.rightAnchor, constant: 16),
            valueTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.6)
            ])
        valueTextField.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        key = ""
        value = ""
        placeholderText = ""
        isValueValid = true
        onValueChanged = nil
        onValueBeingEdited = nil
    }
}

extension TunnelEditTableViewKeyValueCell: NSTextFieldDelegate {
    func controlTextDidBeginEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        textFieldValueOnBeginEditing = textField.stringValue
        isValueValid = true
    }
    func controlTextDidEndEditing(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        let isModified = (textField.stringValue != textFieldValueOnBeginEditing)
        guard (isModified) else { return }
        if let onValueChanged = onValueChanged {
            onValueChanged(textField.stringValue)
        }
    }
    func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        if let onValueBeingEdited = onValueBeingEdited {
            onValueBeingEdited(textField.stringValue)
        }
    }
}

class SectionHeader: NSView {
    var text: String {
        get { return textLabel.stringValue }
        set(value) { textLabel.stringValue = value }
    }

    let textLabel: NSTextField

    override init(frame: NSRect) {
        let textLabel = NSTextField(labelWithString: "Section Header")
        self.textLabel = textLabel

        super.init(frame: frame)

        addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            textLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
            textLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
            ])
        self.wantsLayer = true
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel.stringValue = ""
    }

    override func updateLayer() {
        self.layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        self.textLabel.textColor = NSColor.secondaryLabelColor
    }
}
