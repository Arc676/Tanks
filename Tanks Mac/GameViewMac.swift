//
//  GameViewMac.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
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
Drawing view for the game on Mac
*/
class GameViewMac : GameMgr {

	// Game controls
	let sfxOn = NSImage(named: NSImage.Name(rawValue: "SFXOn.png"))
	let sfxOff = NSImage(named: NSImage.Name(rawValue: "SFXOff.png"))
	let drawButton = NSImage(named: NSImage.Name(rawValue: "Draw.png"))
	// if the size of the view ever changes, these rectangles need to change
	let sfxRect = NSMakeRect(800, 625, 100, 50)
	let drawRect = NSMakeRect(650, 625, 100, 50)

	let shieldRect = NSMakeRect(330, 610, 120, 20)

	let drawAlert = NSAlert()

	// assets for targeted weapons
	let targetSprite = NSImage(named: NSImage.Name(rawValue: "Target.png"))
	var mouseLocation = NSMakePoint(0, 0)

	// Touch Bar controls
	var touchBarRequestedFire: Bool = false
	var touchBarAngleSlider: NSSlider?
	var touchBarFirepowerSlider: NSSlider?

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		uiMarks = [
			NSAttributedString(string: "HP") 		: NSMakePoint(80, bounds.height - 50),
			NSAttributedString(string: "Firepower") : NSMakePoint(40, bounds.height - 70),
			NSAttributedString(string: "Wind") 		: NSMakePoint(210, bounds.height - 40),
			NSAttributedString(string: "Fuel")		: NSMakePoint(210, bounds.height - 70),
			NSAttributedString(string: "Weapon")	: NSMakePoint(330, bounds.height - 20)
		]
		drawAlert.messageText = "Confirm draw"
		drawAlert.informativeText = "Immediately declare this game to be a draw?"
		drawAlert.addButton(withTitle: "No")
		drawAlert.addButton(withTitle: "Yes")
	}

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
	}

	override func draw(_ rect: NSRect) {
		super.draw(rect)

		let active = players[activePlayer]
		var rect: NSRect?

		//draw UI
		NSColor(calibratedWhite: 0.9, alpha: 1).set()
		let bounds = terrain.terrainBounds!
		NSMakeRect(0, bounds.height - 100, bounds.width, 100).fill()

		//draw the little box indicating player color
		let y = bounds.height - playerNames[activePlayer].size().height - 20
		active.tankColor?.set()
		NSMakeRect(35, y, 10, 10).fill()

		//then draw the name
		playerNames[activePlayer].draw(at: NSMakePoint(50, y))

		//draw static text
		for (text, point) in uiMarks! {
			text.draw(at: point)
		}

		//indicate current weapon
		let text = "\(active.weapons[active.selectedWeapon].name) (\(active.weaponCount[active.weapons[active.selectedWeapon].name] ?? 99))"
		text.draw(at: NSMakePoint(330, bounds.height - 40))

		if let shield = active.activeShield {
			let text = "\(shield.name) at \(Int(shield.getShieldPercentage() * 100))%"
			text.draw(at: NSMakePoint(330, bounds.height - 60))
		} else {
			var x: CGFloat = 330
			let y = bounds.height - 90
			for shield in active.shields {
				let rect = NSMakeRect(x, y, 20, 20)
				let path = NSBezierPath(ovalIn: rect)
				shield.color.set()
				path.lineWidth = 3
				path.stroke()
				if NSPointInRect(mouseLocation, rect) {
					let text = "Activate \(shield.name)"
					text.draw(at: NSMakePoint(330, y + 30))
				}
				x += 30
			}
		}

		var scoreY = bounds.height - 30
		for tank in players {
			tank.tankColor?.set()
			let text = NSAttributedString(string: "\(tank.name!): \(tank.score)")
			text.draw(at: NSMakePoint(470, scoreY))
			scoreY -= 20
		}

		NSColor.red.set()

		//draw HP bar
		rect = NSMakeRect(100, bounds.height - 50, 100, 10)
		rect!.frame()
		rect?.size.width = active.hp
		rect!.fill()

		//draw firepower bar
		rect = NSMakeRect(100, bounds.height - 70, 100, 10)
		rect!.frame()
		rect?.size.width = CGFloat(active.firepower)
		rect!.fill()

		//draw wind speed bar
		NSColor.black.set()
		NSMakeRect(259, bounds.height - 55, 2, 20).fill()

		//draw fuel bar (since color is already black)
		rect = NSMakeRect(210, bounds.height - 90, 100, 10)
		rect!.frame()
		rect?.size.width = active.fuel / active.startingFuel * 100
		rect!.fill()

		//fill the wind bar
		NSColor.blue.set()
		rect = NSMakeRect(210, bounds.height - 50, 100, 10)
		rect!.frame()
		if terrain.windAcceleration < 0 {
			rect = NSMakeRect(
				CGFloat(260 + terrain.windAcceleration * 10), bounds.height - 50,
				CGFloat(terrain.windAcceleration * -10), 10)
		} else {
			rect = NSMakeRect(
				260, bounds.height - 50,
				CGFloat(terrain.windAcceleration * 10), 10)
		}
		rect!.fill()

		drawButton?.draw(in: drawRect)
		if GameMgr.enableSFX {
			sfxOn?.draw(in: sfxRect)
		} else {
			sfxOff?.draw(in: sfxRect)
		}

		if active is Player && active.isTargeting {
			targetSprite?.draw(at: NSMakePoint(mouseLocation.x - 20, mouseLocation.y - 20),
							   from: NSZeroRect, operation: .sourceOver, fraction: 1.0)
		}
	}

	override func mouseUp(with event: NSEvent) {
		if sfxRect.contains(event.locationInWindow) {
			GameMgr.enableSFX = !GameMgr.enableSFX
		} else if drawRect.contains(event.locationInWindow) {
			if drawAlert.runModal() == NSApplication.ModalResponse.alertSecondButtonReturn {
				drawGame()
			}
		} else if players[activePlayer].isTargeting && event.locationInWindow.y < 600 {
			players[activePlayer].fireProjectile(at: event.locationInWindow)
		} else if players[activePlayer].shields.count > 0 && NSPointInRect(event.locationInWindow, shieldRect) {
			let index = Int((event.locationInWindow.x - 330) / 30)
			if index >= 0 && index < players[activePlayer].shieldCount.count {
				players[activePlayer].activateShield(index: index)
			}
		} else {
			super.mouseUp(with: event)
		}
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

	override func mouseMoved(with event: NSEvent) {
		mouseLocation = event.locationInWindow
	}

	override func update() {
		if touchBarRequestedFire {
			keyStates[GameMgr.spaceBar] = true
		}
		super.update()
		if players[activePlayer] is Player {
			touchBarAngleSlider?.floatValue = 1 - players[activePlayer].cannonAngle / Float.pi
			touchBarFirepowerSlider?.integerValue = players[activePlayer].firepower
		}
		if touchBarRequestedFire {
			keyStates[GameMgr.spaceBar] = false
			touchBarRequestedFire = false
		}
	}

	/**
	Change the current player's weapon via Touch Bar

	- parameters:
		- dir: 1 to select the next weapon, anything else (-1 for consistency) to select previous weapon
	*/
	func touchBarChangeWeapon(_ dir: Int) {
		if players[activePlayer] is Player {
			if dir == 1 {
				players[activePlayer].selectNextWeapon()
			} else {
				players[activePlayer].selectPreviousWeapon()
			}
		}
	}

	/**
	Set the current player's firing angle via Touch Bar

	- parameters:
		- angle: The coefficient by which π should be multiplied to get the new firing angle
	*/
	func touchBarSetAngle(_ angle: Float) {
		if players[activePlayer] is Player {
			players[activePlayer].cannonAngle = angle * Float.pi
		}
	}

	/**
	Set the current player's firepower via Touch Bar

	- parameters:
		- firepower: The firepower level to set
	*/
	func touchBarSetFirepower(_ firepower: Int) {
		if players[activePlayer] is Player {
			players[activePlayer].firepower = firepower
		}
	}

	/**
	Indicate that the current player should fire as requested by Touch Bar input
	*/
	func touchBarFire() {
		touchBarRequestedFire = true
	}
	
}
