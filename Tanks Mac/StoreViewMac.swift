//
//  StoreViewMac.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

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

class StoreViewMac: Store {

	let continueRect = NSMakeRect(300, 100, 100, 50)
	let saveRect = NSMakeRect(500, 100, 100, 50)

	let continueButton = NSImage(named: NSImage.Name(rawValue: "Next.png"))
	let saveButton = NSImage(named: NSImage.Name(rawValue: "Save.png"))

	override func draw(_ rect: NSRect) {
		let player = players![currentPlayer]
		let text = NSAttributedString(string: "\(player.name!) (\(player.money) credits)")
		text.draw(at: NSMakePoint(80, bounds.height - 50))
		var y = bounds.height - 100
		var x: CGFloat = 100
		for item in storeItems {
			var count = 0
			var color: NSColor?
			if item is Ammo {
				color = NSColor.red
				count = player.weaponCount[item.name] ?? 0
			} else if item is Upgrade {
				color = NSColor.blue
				count = player.upgradeCount[(item as! Upgrade).type.rawValue]
			}
			let text = NSAttributedString(string:
				"\(item.name) (\(item.price)) (\(count) owned)")
			text.draw(at: NSMakePoint(x, y))
			color?.set()
			NSMakeRect(x - 2, y - 2, text.size().width + 4, text.size().height + 4).frame()
			y -= 20
			if (y < 80) {
				x += 300
				y = bounds.height - 100
			}
		}

		continueButton?.draw(in: continueRect)
		saveButton?.draw(in: saveRect)
	}

	override func mouseUp(with event: NSEvent) {
		if continueRect.contains(event.locationInWindow) {
			nextPlayer()
		} else if saveRect.contains(event.locationInWindow) {
			savePlayer()
		} else {
			let i = Int(ceil((bounds.height - 100 - event.locationInWindow.y) / 20))
			purchaseItem(i);
		}
		needsDisplay = true;
	}

	func savePlayer() {
		let panel = NSSavePanel()
		if panel.runModal() == NSApplication.ModalResponse.OK {
			let data = NSKeyedArchiver.archivedData(withRootObject: players![currentPlayer])
			var res = true
			do {
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
