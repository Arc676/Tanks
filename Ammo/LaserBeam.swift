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
	var hits: [Tank] = []
	var terrainHitPos = 0

	override func drawInRect(_ rect: NSRect) {
		if !invalidated() {
			transform.concat()
			laserSprite.draw(in: laserRect!)
			inverse.concat()
		}
	}

	override func fire(angle: Float, firepower: Int, position: NSPoint, terrain: Terrain, tanks: [Tank], src: Int) {
		super.fire(
			angle: angle,
			firepower: firepower,
			position: position,
			terrain: terrain,
			tanks: tanks,
			src: src)
		let c = CGFloat(cos(Double(angle)))
		let s = CGFloat(sin(Double(angle)))

		transform.rotate(byRadians: CGFloat(angle))
		inverse = transform.copy() as! NSAffineTransform
		inverse.invert()
		let nozzlePos = inverse.transform(Ammo.getNozzlePosition(position, cos: c, sin: s, dy: -3.5))
		laserRect = NSMakeRect(nozzlePos.x, nozzlePos.y, 500, 7)

		if cos(angle) != 0 {
			let x0 = entities![sourcePlayer].position.x
			let y0 = entities![sourcePlayer].position.y
			let grad = CGFloat(tan(angle))
			for entity in entities!.filter({ $0.hp > 0 }) {
				if entity.playerNum != sourcePlayer + 1 {
					let y = (entity.position.x - x0) * grad + y0
					if abs(entity.position.y - y) < 4 {
						hits.append(entity)
					}
				}
			}
			var x = 0
			for height in terrain.terrainControlHeights {
				let dx = (CGFloat(x) - x0)
				if dx.sign == grad.sign {
					let y = dx * grad + y0
					if height > y {
						terrainHitPos = x
						break
					}
				}
				x += terrain.chunkSize
			}
		}
	}

	override func update() {
		super.update()
		if !invalidated() {
			if terrainHitPos > 0 {
				terrain?.deform(radius: blastRadius, xPos: terrainHitPos)
			}
			for entity in hits {
				var score: Int = 40
				entity.takeDamage(damage)
				if entity.hp <= 0 {
					score *= 2
				}
				entities![sourcePlayer].money += score
				entities![sourcePlayer].score += 2 * score
			}
		}
	}

	override func reset() {
		super.reset()
		transform = NSAffineTransform()
		hits.removeAll()
		terrainHitPos = -1
	}
	
}
