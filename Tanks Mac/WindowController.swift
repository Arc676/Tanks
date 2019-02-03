//
//  WindowController.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 04/06/2018.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018-9 Arc676/Alessandro Vinciguerra

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

class WindowController: NSWindowController {

	var viewController: GameViewController?

	@IBOutlet weak var touchBarAngleSlider: NSSlider!
	@IBOutlet weak var touchBarFirepowerSlider: NSSlider!

	override func awakeFromNib() {
		window?.acceptsMouseMovedEvents = true
		viewController = contentViewController as? GameViewController
		viewController?.windowController = self
	}

	/**
	Select the previous weapon via Touch Bar

	- parameters:
		- sender: The touch bar item that sent the request
	*/
	@IBAction func touchBarPrevWeapon(_ sender: NSButton) {
		viewController?.gameView?.touchBarChangeWeapon(-1)
	}

	/**
	Select the next weapon via Touch Bar

	- parameters:
		- sender: The touch bar item that sent the request
	*/
	@IBAction func touchBarNextWeapon(_ sender: NSButton) {
		viewController?.gameView?.touchBarChangeWeapon(1)
	}

	/**
	Change the firing angle via Touch Bar

	- parameters:
		- sender: The touch bar item that sent the request
	*/
	@IBAction func touchBarChangeAngle(_ sender: NSSlider) {
		viewController?.gameView?.touchBarSetAngle(1 - sender.floatValue)
	}

	/**
	Change the firepower via Touch Bar

	- parameters:
		- sender: The touch bar item that sent the request
	*/
	@IBAction func touchBarChangeFirepower(_ sender: NSSlider) {
		viewController?.gameView?.touchBarSetFirepower(sender.integerValue)
	}

	/**
	Fire via Touch Bar

	- parameters:
		- sender: The touch bar item that sent the request
	*/
	@IBAction func touchBarFire(_ sender: NSButton) {
		viewController?.gameView?.touchBarFire()
	}
	
}
