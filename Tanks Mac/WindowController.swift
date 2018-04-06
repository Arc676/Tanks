//
//  WindowController.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 04/06/2018.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

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

	override func awakeFromNib() {
		viewController = contentViewController as? GameViewController
	}

	@IBAction func touchBarPrevWeapon(_ sender: NSButton) {
		viewController?.gameView?.touchBarChangeWeapon(-1)
	}

	@IBAction func touchBarNextWeapon(_ sender: NSButton) {
		viewController?.gameView?.touchBarChangeWeapon(1)
	}

	@IBAction func touchBarChangeAngle(_ sender: NSSlider) {
		viewController?.gameView?.touchBarSetAngle(1 - sender.floatValue)
	}

	@IBAction func touchBarChangeFirepower(_ sender: NSSlider) {
		viewController?.gameView?.touchBarSetFirepower(sender.integerValue)
	}

	@IBAction func touchBarFire(_ sender: NSButton) {
		viewController?.gameView?.touchBarFire()
	}
	
}
