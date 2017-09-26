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

	let continueButton = NSMakeRect(300, 100, 100, 10)

	override func draw(_ rect: NSRect) {
		let player = players![currentPlayer]
		let text = NSAttributedString(string: "\(player.name!) ($\(player.money))")
		text.draw(at: NSMakePoint(80, bounds.height - 50))
		var y = bounds.height - 100
		var x: CGFloat = 100
		for item in storeItems {
			let text = NSAttributedString(string:
				"\(item.name) (\(item.price)) (\(player.weaponCount[item.name] ?? 0) owned)")
			text.draw(at: NSMakePoint(x, y))
			y -= 20
			if (y < 80) {
				x += 300
				y = bounds.height - 100
			}
		}

		NSColor.white.set()
		NSRectFill(continueButton)
	}

	override func mouseUp(with event: NSEvent) {
		if continueButton.contains(event.locationInWindow) {
			nextPlayer()
		} else {
			let i = Int(ceil((bounds.height - 100 - event.locationInWindow.y) / 20))
			purchaseItem(i);
		}
		needsDisplay = true;
	}
	
}
