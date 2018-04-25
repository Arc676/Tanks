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
	var reqHeight: CGFloat = 0
	
	var basisNozzlePos: NSPoint?
	var grad: CGFloat = 0
	var cosine: CGFloat = 0

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

		cosine = CGFloat(cos(Double(angle)))
		let s = CGFloat(sin(Double(angle)))

		if cosine != 0 {
			grad = CGFloat(tan(angle))
		}

		transform.rotate(byRadians: CGFloat(angle))
		inverse = transform.copy() as! NSAffineTransform
		inverse.invert()

		basisNozzlePos = Ammo.getNozzlePosition(position, cos: cosine, sin: s, dy: -3.5)

		let nozzlePos = inverse.transform(basisNozzlePos!)
		laserRect = NSMakeRect(nozzlePos.x, nozzlePos.y, 1000, 7)

		beamRaycast()
	}

	override func update() {
		super.update()
		if !invalidated() {
			if terrainHitPos > 0 {
				terrain?.deform(radius: blastRadius, xPos: terrainHitPos)
				if terrain!.terrainControlHeights[terrainHitPos / terrain!.chunkSize] < reqHeight {
					beamRaycast()
				}
			}
			for entity in hits.filter({ $0.hp > 0 }) {
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

	/**
	Perform a raycast-like operation to determine where the laser
	will first collide with the terrain and which entities will be
	hit by the beam
	*/
	func beamRaycast() {
		// reset data points
		terrainHitPos = -1
		hits.removeAll()

		var dx: CGFloat = 0
		// only perform raycast if the beam isn't going straight up
		if cosine != 0 {
			var x = 0
			for height in terrain!.terrainControlHeights {
				dx = (CGFloat(x) - basisNozzlePos!.x)
				// the beam only goes upward relative to the firing tank;
				// sgn(dx) ≠ sgn(grad) implies that we are looking at the part
				// behind the nozzle rather than ahead
				if dx.sign == grad.sign {
					let y = dx * grad + basisNozzlePos!.y
					// if the terrain is higher than the beam at this point, collide
					if height > y {
						terrainHitPos = x
						reqHeight = y
						break
					}
				}
				x += terrain!.chunkSize
			}

			// search living entities for those that would be hit by the beam
			for entity in entities!.filter({ $0.hp > 0 }) {
				// ignore firing player
				if entity.playerNum != sourcePlayer + 1 {
					// if the beam hits the terrain, ignore entities placed after
					// the collision point with the terrain
					if terrainHitPos < 0 || entity.position.x <= CGFloat(terrainHitPos) {
						let y = (entity.position.x - basisNozzlePos!.x) * grad + basisNozzlePos!.y
						// allow a deviation of 10 for collision
						if abs(entity.position.y - y) < 10 {
							hits.append(entity)
						}
					}
				}
			}
		}
		// resize the rectangle representing the beam for drawing
		laserRect?.size.width = terrainHitPos > 0 ? dx / cosine : 1000
	}

	override func reset() {
		super.reset()
		transform = NSAffineTransform()
		hits.removeAll()
		terrainHitPos = -1
	}
	
}
