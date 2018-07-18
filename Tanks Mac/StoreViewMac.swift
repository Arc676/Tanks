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

	@IBOutlet weak var storeTable: NSTableView!

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
		playerCredits.integerValue = player.money
		playerColor.color = player.tankColor!

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
		} else if item is Shield {
			type = "Shield"
			count = player.shieldCount[item.name] ?? 0
		}
		switch tableColumn?.title {
		case "Item Name":
			return item.name
		case "Item Type":
			return type
		case "Price":
			return item.price
		case "Amount owned":
			return count
		default:
			return ""
		}
	}

	@IBAction func moveToNext(_ sender: Any) {
		nextPlayer()
		refresh()
	}

	@IBAction func savePlayerToDisk(_ sender: Any) {
		savePlayer()
	}

	@IBAction func saveAITanks(_ sender: NSButton) {
		saveAIs = sender.state == NSControl.StateValue.on
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

	override func savePlayer() {
		let panel = NSSavePanel()
		panel.allowedFileTypes = ["plist"]
		panel.message = "Select save location for Player \(currentPlayer + 1) (\(players![currentPlayer].name!))"
		if panel.runModal() == NSApplication.ModalResponse.OK {
			var res = true
			do {
				let data = NSKeyedArchiver.archivedData(withRootObject: players![currentPlayer])
				try data.write(to: panel.url!)
			} catch {
				res = false
			}
			let alert = NSAlert()
			alert.messageText = res ? "Saved" : "Save failed"
			alert.runModal()
		}
	}
	
}
