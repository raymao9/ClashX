//
//  AboutViewController.swift
//  ClashX
//
//  Created by CYC on 2018/8/19.
//  Copyright © 2018年 west2online. All rights reserved.
//

import Cocoa

class AboutViewController: NSViewController {
    @IBOutlet var versionLabel: NSTextField!
    @IBOutlet var buildTimeLabel: NSTextField!
    @IBOutlet var coreVersionLabel: NSTextField!

    lazy var clashCoreVersion: String = {
        return Bundle.main.infoDictionary?["coreVersion"] as? String ?? ""
    }()

    lazy var commit: String = {
        return Bundle.main.infoDictionary?["gitCommit"] as? String ?? ""
    }()

    lazy var branch: String = {
        return Bundle.main.infoDictionary?["gitBranch"] as? String ?? ""
    }()

    lazy var buildTime: String = {
        return Bundle.main.infoDictionary?["buildTime"] as? String ?? "Modified by Raymao9 (2021-10-06)"
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "About"

        let version = AppVersionUtil.currentVersion
        let build = AppVersionUtil.currentBuild
        let isBeta = AppVersionUtil.isBeta ? " Beta" : ""

        versionLabel.stringValue = "Version: \(version) (\(build))\(isBeta)"
        coreVersionLabel.stringValue = clashCoreVersion
        buildTimeLabel.stringValue = "\(commit)-\(branch) \(buildTime)"
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.styleMask.remove(.resizable)
        view.window?.makeKeyAndOrderFront(self)
        view.window?.level = .floating
        NSApp.activate(ignoringOtherApps: true)
    }
}

@IBDesignable
class HyperlinkTextField: NSTextField {
    @IBInspectable var href: String = ""

    override func resetCursorRects() {
        discardCursorRects()
        addCursorRect(bounds, cursor: NSCursor.pointingHand)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: NSColor.linkColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue as AnyObject,
        ]
        attributedStringValue = NSAttributedString(string: stringValue, attributes: attributes)
    }

    override func mouseDown(with theEvent: NSEvent) {
        if let localHref = URL(string: href) {
            NSWorkspace.shared.open(localHref)
        }
    }
}
