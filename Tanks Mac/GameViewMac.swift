//
//  GameViewMac.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.

//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.
//See README and LICENSE for more details

import Cocoa

class GameViewMac : GameMgr {

	override func initialize(terrainType: TerrainType, players: [Tank]) {
		uiMarks = [
			NSAttributedString(string: "HP") 		: NSMakePoint(80, bounds.height - 50),
			NSAttributedString(string: "Firepower") : NSMakePoint(40, bounds.height - 70),
			NSAttributedString(string: "Wind") 		: NSMakePoint(210, bounds.height - 40)
		]
	}

	override func draw(_ rect: NSRect) {
		super.draw(rect)

		let active = players[activePlayer]
		var rect: NSRect?

		//draw UI
		NSColor(calibratedWhite: 0.9, alpha: 1).set()
		let bounds = terrain.terrainBounds!
		NSRectFill(NSMakeRect(0, bounds.height - 100, bounds.width, 100))

		let y = bounds.height - playerNames[activePlayer].size().height - 20
		active.tankColor?.set()
		NSRectFill(NSMakeRect(35, y, 10, 10))

		playerNames[activePlayer].draw(at: NSMakePoint(50, y))

		for (text, point) in uiMarks! {
			text.draw(at: point)
		}

		NSColor.red.set()

		//draw HP bar
		rect = NSMakeRect(100, bounds.height - 50, 100, 10)
		NSFrameRect(rect!)
		rect?.size.width = CGFloat(active.hp)
		NSRectFill(rect!)

		//draw firepower bar
		rect = NSMakeRect(100, bounds.height - 70, 100, 10)
		NSFrameRect(rect!)
		rect?.size.width = CGFloat(active.firepower)
		NSRectFill(rect!)

		//draw wind speed bar
		NSColor.black.set()
		NSRectFill(NSMakeRect(259, bounds.height - 55, 2, 20))

		NSColor.blue.set()
		rect = NSMakeRect(210, bounds.height - 50, 100, 10)
		NSFrameRect(rect!)
		if terrain.windAcceleration < 0 {
			rect = NSMakeRect(
				CGFloat(260 + terrain.windAcceleration * 10), bounds.height - 50,
				CGFloat(terrain.windAcceleration * -10), 10)
		} else {
			rect = NSMakeRect(
				260, bounds.height - 50,
				CGFloat(terrain.windAcceleration * 10), 10)
		}
		NSRectFill(rect!)
	}

	override func keyDown(with event: NSEvent) {
		if relevantKeys.contains(where: { $0 == event.keyCode }) {
			keyStates[event.keyCode] = true
		} else {
			super.keyDown(with: event)
		}
	}

	override func keyUp(with event: NSEvent) {
		if relevantKeys.contains(where: { $0 == event.keyCode }) {
			keyStates[event.keyCode] = false
		} else {
			super.keyUp(with: event)
		}
	}
	
}
