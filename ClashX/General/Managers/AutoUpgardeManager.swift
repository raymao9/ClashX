//
//  AutoUpgardeManager.swift
//  ClashX
//
//  Created by yicheng on 2019/10/28.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa
import Sparkle

class AutoUpgardeManager: NSObject {
    static let shared = AutoUpgardeManager()

    private var current: Channel = {
        if let value = UserDefaults.standard.object(forKey: "AutoUpgardeManager.current") as? Int,
            let channel = Channel(rawValue: value) { return channel }
        return .stable
    }() {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "AutoUpgardeManager.current")
        }
    }

    private lazy var menuItems: [Channel: NSMenuItem] = {
        var items = [Channel: NSMenuItem]()
        for channel in Channel.allCases {
            let item = NSMenuItem(title: channel.title, action: #selector(didSelectUpgradeChannel(_:)), keyEquivalent: "")
            item.target = self
            item.tag = channel.rawValue
            items[channel] = item
        }
        return items
    }()

    // MARK: Public

    func setup() {
        guard WebPortalManager.hasWebProtal == false else { return }
        SUUpdater.shared()?.delegate = self
    }

    func addChanelMenuItem(_ menu: inout NSMenu) {
        guard WebPortalManager.hasWebProtal == false else { return }
        let upgradeMenu = NSMenu(title: NSLocalizedString("Upgrade Channel", comment: ""))
        for (_, item) in menuItems {
            upgradeMenu.addItem(item)
        }

        let upgradeMenuItem = NSMenuItem(title: NSLocalizedString("Upgrade Channel", comment: ""), action: nil, keyEquivalent: "")
        upgradeMenuItem.submenu = upgradeMenu
        menu.addItem(upgradeMenuItem)
        updateDisplayStatus()
    }
}

extension AutoUpgardeManager {
    @objc private func didSelectUpgradeChannel(_ menuItem: NSMenuItem) {
        guard let channel = Channel(rawValue: menuItem.tag) else { return }
        current = channel
        updateDisplayStatus()
    }

    private func updateDisplayStatus() {
        for (channel, menuItem) in menuItems {
            menuItem.state = channel == current ? .on : .off
        }
    }
}

extension AutoUpgardeManager: SUUpdaterDelegate {
    func feedURLString(for updater: SUUpdater) -> String? {
        return current.urlString
    }

    func updaterWillRelaunchApplication(_ updater: SUUpdater) {
        SystemProxyManager.shared.disableProxy(port: 0, socksPort: 0, forceDisable: true)
    }
}

// MARK: - Channel Enum

extension AutoUpgardeManager {
    enum Channel: Int, CaseIterable {
        case stable
        case prelease
        case appcenter
    }
}

extension AutoUpgardeManager.Channel {
    var title: String {
        switch self {
        case .stable:
            return NSLocalizedString("Stable", comment: "")
        case .prelease:
            return NSLocalizedString("Prelease", comment: "")
        case .appcenter:
            return "Appcenter"
        }
    }

    var urlString: String {
        switch self {
        case .stable:
            return "https://gitee.com/raymao9/appcast_clashx/raw/master/appcast.xml"
        case .prelease:
            return "https://gitee.com/raymao9/appcast_clashx/raw/master/appcast_pre.xml"
        case .appcenter:
            return "https://gitee.com/raymao9/appcast_clashx/raw/master/appcast.xml"
        }
    }
}
