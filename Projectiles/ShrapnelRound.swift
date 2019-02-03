//
//  ShrapnelRound.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/04/25.
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
A projectile that separates into several smaller
projectiles that also deal damage on impact
*/
class ShrapnelRound: Projectile {

	var subProjectiles: [Projectile] = []
	var primaryImpactDone = false

	init(copyOf projectile: Projectile) {
		super.init(
			terrain: projectile.terrain!,
			entities: projectile.entities!,
			vx: projectile.vx,
			vy: projectile.vy,
			pos: projectile.position,
			src: projectile.sourcePlayer!,
			ammo: projectile.ammo)
	}

	override func drawInRect(_ rect: NSRect) {
		if primaryImpactDone {
			for projectile in subProjectiles {
				projectile.drawInRect(rect)
			}
		} else {
			super.drawInRect(rect)
		}
	}

	override func despawn() {
		if isOutOfBounds() {
			invalidated = true
		} else {
			primaryImpactDone = true
			for _ in 0...4 {
				let projectile = Projectile(
					terrain: terrain!,
					entities: entities!,
					vx: CGFloat(arc4random_uniform(41)) - 20,
					vy: CGFloat(arc4random_uniform(41)) - 20,
					pos: NSMakePoint(position.x, position.y + 5),
					src: sourcePlayer!,
					ammo: ammo)
				subProjectiles.append(projectile)
			}
		}
	}

	override func update() {
		if primaryImpactDone {
			invalidated = true
			for projectile in subProjectiles {
				projectile.update()
				if !projectile.invalidated {
					invalidated = false
				}
			}
		} else {
			super.update()
		}
	}
	
}
