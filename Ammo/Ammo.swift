//
//  Ammo.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
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
Representation of different kinds of ammunition
*/
class Ammo: Item {

	var isTargeted: Bool { return false }
	var hasSound: Bool { return false }

	var blastRadius: Int
	var damage: CGFloat

	var soundFile: NSSound

	var projectiles: [Projectile] = []

	/**
	Create a new Ammo object

	- parameters:
		- name: Name of ammunition type
		- price: Price of the ammunition
		- radius: Blast radius for this type of ammunition
		- damage: Damage dealt by the ammunition at zero range
		- sound: The sound file to be played on impact
	*/
	init(_ name: String, price: Int, radius: Int, damage: CGFloat, sound: NSSound) {
		blastRadius = radius
		self.damage = damage
		soundFile = sound
		super.init(name, price: price)
	}

	override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(blastRadius, forKey: "BlastRadius")
		aCoder.encode(damage, forKey: "Dmg")
		aCoder.encode(soundFile, forKey: "Sound")
	}

	required init?(coder aDecoder: NSCoder) {
		blastRadius = aDecoder.decodeInteger(forKey: "BlastRadius")
		damage = aDecoder.decodeObject(forKey: "Dmg") as! CGFloat
		soundFile = aDecoder.decodeObject(forKey: "Sound") as! NSSound
		super.init(coder: aDecoder)
	}

	/**
	Draws the projectiles associated with the ammunition given the rectangle of the view

	- parameters:
		- rect: The view rectangle
	*/
	func drawInRect(_ rect: NSRect) {
		for projectile in projectiles {
			projectile.drawInRect(rect)
		}
	}

	/**
	Starts the firing process for the ammunition

	- parameters:
		- angle: The cannon angle upon firing
		- firepower: The firepower used when firing
		- position: The position of the firing tank
		- terrain: The current terrain
		- tanks: A list of the entities on the battlefield
		- src: The player number of the firing tank
	*/
	func fire(angle: Float, firepower: Int, position: NSPoint, terrain: Terrain, tanks: [Tank], src: Int) {
		let c = CGFloat(cos(Double(angle)))
		let s = CGFloat(sin(Double(angle)))

		let vx = CGFloat(firepower) * c
		let vy = CGFloat(firepower) * s
		let pos = NSMakePoint(position.x + 20 * c, position.y + 5 + 20 * s)

		let projectile = Projectile(
			terrain: terrain,
			entities: tanks,
			vx: vx,
			vy: vy,
			pos: pos,
			src: src,
			ammo: self)
		projectiles.append(projectile)
	}

	/**
	Determine if the all projectiles associated with the ammunition are invalidated

	- returns:
	Whether all projectiles have been invalidated and thus the ammunition has
	been invalidated
	*/
	func invalidated() -> Bool {
		for projectile in projectiles {
			if !projectile.invalidated {
				return false
			}
		}
		return true
	}

	/**
	Updates all projectiles associated with the ammunition
	*/
	func update() {
		for projectile in projectiles {
			projectile.update()
		}
	}

	/**
	Resets the ammunition's state
	*/
	func reset() {
		projectiles.removeAll()
	}

}
