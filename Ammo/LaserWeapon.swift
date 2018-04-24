//
//  LaserWeapon.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/04/24.
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

import Foundation
import AppKit

class LaserWeapon: Ammo {

	let laserSound = NSSound(named: NSSound.Name("laser.wav"))!

	override var hasSound: Bool { return true }

	var ticksSinceFiring = 0
	var tickLimit: Int { return 0 }

	override func invalidated() -> Bool {
		return ticksSinceFiring > tickLimit
	}

	override func update() {
		if !laserSound.isPlaying {
			GameMgr.playSound(laserSound)
		}
		ticksSinceFiring++
	}

	override func reset() {
		ticksSinceFiring = 0
		laserSound.stop()
	}

}
