//
//  LaserBeam.swift
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

class LaserBeam: LaserWeapon {

	let laserSprite = NSImage(named: NSImage.Name("LaserBeam.png"))!

	override var tickLimit: Int { return 30 }

	var transform = NSAffineTransform()
	var inverse = NSAffineTransform()

	var laserRect: NSRect?

	override func drawInRect(_ rect: NSRect) {
		if !invalidated() {
			transform.concat()
			laserSprite.draw(in: laserRect!)
			inverse.concat()
		}
	}

	override func fire(angle: Float, firepower: Int, position: NSPoint, terrain: Terrain, tanks: [Tank], src: Int) {
		let c = CGFloat(cos(Double(angle)))
		let s = CGFloat(sin(Double(angle)))

		transform.rotate(byRadians: CGFloat(angle))
		inverse = transform.copy() as! NSAffineTransform
		inverse.invert()
		let nozzlePos = inverse.transform(Ammo.getNozzlePosition(position, cos: c, sin: s, dy: -3.5))
		laserRect = NSMakeRect(nozzlePos.x, nozzlePos.y, 500, 7)
	}

	override func reset() {
		super.reset()
		transform = NSAffineTransform()
	}
	
}
