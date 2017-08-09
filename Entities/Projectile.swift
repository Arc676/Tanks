//
//  Projectile.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 25/07/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

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

class Projectile : NSObject {

	var position = NSMakePoint(0, 0)
	var vx: CGFloat = 0
	var vy: CGFloat = 0

	var blastRadius: CGFloat = 20
	var hasImpacted = false

	var terrain: Terrain?
	var entities: [Tank]?

	init(terrain: Terrain, entities: [Tank], vx: CGFloat, vy: CGFloat, pos: NSPoint) {
		self.terrain = terrain
		self.entities = entities
		self.vx = vx
		self.vy = vy
		self.position = pos
	}

	func drawInRect(_ rect: NSRect) {
		NSColor.black.set()
		NSBezierPath(ovalIn: NSMakeRect(position.x, position.y, 5, 5)).fill()
	}

	func despawn() {
		hasImpacted = true
	}

	func impact() {
		terrain?.deform(radius: blastRadius, xPos: Int(position.x))
		for entity in entities! {
			if hypot(entity.position.x - position.x, entity.position.y - position.y) <= blastRadius {
				entity.takeDamage(Int(blastRadius))
			}
		}
		despawn()
	}

	func update() {
		//update position
		position.x +/= vx
		position.y +/= vy

		//update velocity vectors
		vx +/= CGFloat((terrain?.windAcceleration)!)
		vy +/= -9.81

		if (terrain?.terrainPath?.contains(position))! {
			impact()
		} else if position.x < 0 || position.x > (terrain?.terrainBounds?.width)! {
			despawn()
		}
	}

}
