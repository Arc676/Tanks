//
//  Hailfire.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/04/11.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017-9 Arc676/Alessandro Vinciguerra

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
Ammunition that separates into multiple smaller
projectiles while traveling through the air
*/
class Hailfire: SeparationWeapon {

	override func fire(angle: Float, firepower: Int, position: NSPoint, terrain: Terrain, tanks: [Tank], src: Int) {
		let c = CGFloat(cos(Double(angle)))
		let s = CGFloat(sin(Double(angle)))

		let vx = CGFloat(firepower) * c
		let vy = CGFloat(firepower) * s

		let pos = tanks[src].getNozzlePosition()

		for i in 0..<projCount {
			let dv = CGFloat(2 * i)
			let projectile = Projectile(
				terrain: terrain,
				entities: tanks,
				vx: vx + dv,
				vy: vy,
				pos: pos,
				src: src,
				ammo: self)
			projectiles.append(projectile)
		}
	}
	
}
