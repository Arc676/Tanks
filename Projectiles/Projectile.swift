//
//  Projectile.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 25/07/2017.
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

import Foundation
import AppKit

/**
Represents individual projectiles with properties
determined by the ammo type
*/
class Projectile : NSObject {

	var explosion: Explosion?

	var position = NSMakePoint(0, 0)
	var vx: CGFloat = 0
	var vy: CGFloat = 0

	var ammo: Ammo

	var invalidated = false
	var impacted = false

	var terrain: Terrain?
	var entities: [Tank]?
	var sourcePlayer: Int?

	/**
	Create a new projectile

	- parameters:
		- terrain: The terrain of the map
		- entities: A list of entities currently on the map
		- vx: The horizontal component of the projectile's initial velocity
		- vy: The vertical component of the projectile's initial velocity
		- pos: The projectile's spawn position
		- src: The player number of the tank that fired the projectile
		- ammo: The type of ammunition being fired
	*/
	init(terrain: Terrain, entities: [Tank], vx: CGFloat, vy: CGFloat, pos: NSPoint, src: Int, ammo: Ammo) {
		self.terrain = terrain
		self.entities = entities
		self.vx = vx
		self.vy = vy
		self.position = pos

		self.ammo = ammo
		sourcePlayer = src
	}

	/**
	Draws the projectile given the rectangle of the view

	- parameters:
		- rect: The view rectangle
	*/
	func drawInRect(_ rect: NSRect) {
		// Do nothing if projectile is no longer valid
		if invalidated {
			return
		}
		if impacted {
			explosion?.draw()
		} else {
			NSColor.black.set()
			NSBezierPath(ovalIn: NSMakeRect(position.x, position.y, 5, 5)).fill()
		}
	}

	/**
	Indicate that the projectile should despawn
	*/
	func despawn() {
		invalidated = true
	}

	/**
	Indicate that the projectile has impacted and cause
	damage to terrain and entities accordingly
	*/
	func impact() {
		GameMgr.playSound(ammo.soundFile, copy: true)
		let radius = CGFloat(ammo.blastRadius)
		terrain?.deform(radius: Int(ammo.blastRadius), xPos: Int(position.x))
		for entity in entities!.filter({ $0.hp > 0 }) {
			let distance = hypot(entity.position.x - position.x, entity.position.y - position.y)
			if distance <= radius {
				var score: Int = 2 * Int(50 * radius / max(1, distance))
				let dmg = distance > 10 ? ammo.damage / pow(distance / 20, 2) : ammo.damage * 1.5
				entity.takeDamage(dmg)
				if entity.hp <= 0 {
					score *= 2
				}
				if entity.playerNum == sourcePlayer! + 1 {
					score *= -1
				} else {
					entities![sourcePlayer!].money += score + score / 2
				}
				entities![sourcePlayer!].score += score
			}
		}
		impacted = true
		explosion = Explosion(Float(self.ammo.blastRadius), pos: position)
	}

	/**
	Check whether the projectile is outside of the map bounds (either horizontally or Y < 0)
	*/
	func isOutOfBounds() -> Bool {
		return position.x < 0 || position.x > (terrain?.terrainBounds?.width)! || position.y < 0
	}

	/**
	Update the projectile's position and velocity based on
	the environment and call appropriate methods to destroy
	the projectile if necessary
	*/
	func update() {
		// Do nothing if projectile is no longer valid
		if invalidated {
			return
		}

		if impacted {
			explosion?.update()
			if explosion?.isDone() ?? false {
				despawn()
			}
		} else {
			//update position
			position.x +/= vx
			position.y +/= vy

			//update velocity vectors
			vx +/= CGFloat((terrain?.windAcceleration)!)
			vy +/= -9.81

			if isOutOfBounds() {
				despawn()
			} else {
				var hasImpacted = terrain!.terrainPath!.contains(position)
				if !hasImpacted {
					for tank in entities!.filter({ $0.hp > 0 }) {
						if tank.hitTank(position) {
							hasImpacted = true
							break
						}
					}
				}

				if hasImpacted {
					impact()
				}
			}
		}
	}

}
