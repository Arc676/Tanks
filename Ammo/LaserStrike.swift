//
//  LaserStrike.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/04/24.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018-9 Arc676/Alessandro Vinciguerra

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
Fires a laser from the sky that destroys the terrain at
a target point chosen by the user
*/
class LaserStrike: LaserWeapon {

	let laserSprite = NSImage(named: NSImage.Name(rawValue: "LaserStrike.png"))!

	override var isTargeted: Bool { return true }

	override var tickLimit: Int { return 60 }

	var xPos: CGFloat = 0
	var laserRect: NSRect?

	override func drawInRect(_ rect: NSRect) {
		if !invalidated() {
			laserSprite.draw(in: laserRect!)
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
		xPos = position.x
		laserRect = NSMakeRect(xPos - 20, 0, 40, 700)
	}

	override func update() {
		super.update()
		if !invalidated() {
			terrain?.deform(radius: blastRadius, xPos: Int(xPos))
			for entity in entities!.filter({ $0.hp > 0 }) {
				if NSIntersectsRect(entity.tankRect(), laserRect!) {
					var score: Int = 40
					entity.takeDamage(damage)
					if entity.hp <= 0 {
						score *= 2
					}
					if entity.playerNum == sourcePlayer + 1 {
						score *= -1
					} else {
						entities![sourcePlayer].money += score
					}
					entities![sourcePlayer].score += 2 * score
				}
			}
		}
	}

}
