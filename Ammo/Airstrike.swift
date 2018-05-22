//
//  Airstrike.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/04/23.
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

/**
Drops projectiles from the sky to land around a
target point on the map chosen by the user
*/
class Airstrike : SeparationWeapon {

	let planeSound = NSSound(named: NSSound.Name("bomber.wav"))!

	override var isTargeted: Bool { return true }
	override var hasSound: Bool { return true }

	override func fire(angle: Float, firepower: Int, position: NSPoint, terrain: Terrain, tanks: [Tank], src: Int) {
		GameMgr.playSound(planeSound)
		for i in (-self.projCount / 2)...(self.projCount / 2) {
			let pos = NSMakePoint(position.x + CGFloat(i * 20), 700)
			let projectile = Projectile(
				terrain: terrain,
				entities: tanks,
				vx: 0,
				vy: 0,
				pos: pos,
				src: src,
				ammo: self)
			projectiles.append(projectile)
		}
	}
	
}
