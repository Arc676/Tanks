//
//  StoreViewMac.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017-8 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation (version 3)

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

/**
View for store control on Mac
*/
class StoreViewMac: Store, NSTableViewDelegate, NSTableViewDataSource {

	@IBOutlet weak var playerName: NSTextField!
	@IBOutlet weak var playerCredits: NSTextField!
	@IBOutlet weak var playerColor: NSColorWell!

	@IBOutlet weak var purchaseButton: NSButton!
	@IBOutlet weak var storeTable: NSTableView!

	@IBOutlet weak var useSamePath: NSButton!
	@IBOutlet weak var path: NSPathControl!
	var savePaths: [URL?] = [
		nil, nil, nil, nil
	]
	
	@IBOutlet weak var contentView: NSView?

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		xibSetup()
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		xibSetup()
	}

	/**
	Load the view from the XIB file
	*/
	func xibSetup() {
		Bundle.main.loadNibNamed(NSNib.Name("Store"), owner: self, topLevelObjects: nil)
		addSubview(contentView!)
		contentView?.frame = self.bounds
	}

	/**
	Reloads tank properties for the current player and updates the UI
	*/
	func refresh() {
		let player = players![currentPlayer]

		playerName.stringValue = player.name!
		if player is Player {
			playerCredits.integerValue = player.money
		} else {
			playerCredits.stringValue = "Unknown"
		}
		playerColor.color = player.tankColor!

		useSamePath.isEnabled = savePaths[currentPlayer] != nil
		path.url = savePaths[currentPlayer]

		purchaseButton.isEnabled = players![currentPlayer] is Player

		storeTable.reloadData()
	}

	func numberOfRows(in tableView: NSTableView) -> Int {
		return storeItems.count
	}

	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		let item = storeItems[row]
		let player = players![currentPlayer]
		var type = ""
		var count = 0
		if item is Ammo {
			type = "Ammo"
			count = player.weaponCount[item.name] ?? 0
		} else if item is Upgrade {
			type = "Upgrade"
			count = player.upgradeCount[(item as! Upgrade).type.rawValue]
		} else {
			if item is Shield {
				type = "Shield"
			} else {
				type = "Item"
			}
			count = player.itemCount[item.name] ?? 0
		}
		switch tableColumn?.title {
		case "Item Name":
			return item.name
		case "Item Type":
			return type
		case "Price":
			return item.price
		case "Amount owned":
			if player is Player {
				return count
			}
			return "Unknown"
		default:
			return ""
		}
	}

	@IBAction func moveToNext(_ sender: NSButton?) {
		nextPlayer()
		refresh()
	}

	@IBAction func savePlayerToDisk(_ sender: NSButton?) {
		savePlayer()
	}

	@IBAction func saveAndNext(_ sender: Any) {
		if savePlayer() {
			moveToNext(nil)
		}
	}

	@IBAction func exitToMain(_ sender: Any) {
		viewController?.exitToMain()
	}

	@IBAction func makePurchase(_ sender: Any) {
		purchaseItem(storeTable.selectedRow)
		refresh()
	}

	@IBAction func nameChanged(_ sender: NSTextField) {
		if players != nil {
			players![currentPlayer].name = sender.stringValue
		}
	}

	@IBAction func colorChanged(_ sender: NSColorWell) {
		if players != nil {
			players![currentPlayer].tankColor = sender.color
		}
	}

	override func savePlayer() -> Bool {
		if useSamePath.state == NSControl.StateValue.off || savePaths[currentPlayer] == nil {
			let panel = NSSavePanel()
			panel.allowedFileTypes = ["plist"]
			panel.message = "Select save location for Player \(currentPlayer + 1) (\(players![currentPlayer].name!))"
			if panel.runModal() == NSApplication.ModalResponse.OK {
				savePaths[currentPlayer] = panel.url!
			} else {
				return false
			}
		}
		var res = true
		do {
			let data = NSKeyedArchiver.archivedData(withRootObject: players![currentPlayer])
			try data.write(to: savePaths[currentPlayer]!)
			path.url = savePaths[currentPlayer]
		} catch {
			res = false
		}
		if !res {
			let alert = NSAlert()
			alert.messageText = "Save failed"
			alert.runModal()
		}
		return res
	}
	
}
