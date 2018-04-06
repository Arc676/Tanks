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

	@IBAction func touchBarPrevWeapon(_ sender: NSButton) {
		Swift.print("Prev weapon")
	}

	@IBAction func touchBarNextWeapon(_ sender: NSButton) {
		Swift.print("Next weapon")
	}

	@IBAction func touchBarChangeAngle(_ sender: NSSliderTouchBarItem) {
		Swift.print("Angle changed")
	}

	@IBAction func touchBarChangeFirepower(_ sender: NSSliderTouchBarItem) {
		Swift.print("Firepower changed")
	}

	@IBAction func touchBarMoveLeft(_ sender: NSButton) {
		Swift.print("Move left")
	}

	@IBAction func touchBarMoveRight(_ sender: NSButton) {
		Swift.print("Move right")
	}
	
}
