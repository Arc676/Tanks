//
//  Explosion.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 11/08/2018.
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
Encapsulates the drawing and internal calculations of explosion animations
*/
class Explosion: NSObject {

	static let explosionSprite = NSImage(named: NSImage.Name("Explosion.png"))!

	var position: NSPoint
	var explosionRect: NSRect?
	var explosionTicks: Float
	var explosionLimit: Float

	init(_ limit: Float, pos: NSPoint) {
		explosionTicks = 0
		explosionLimit = limit
		position = pos
	}

	func draw() {
		if explosionRect != nil {
			Explosion.explosionSprite.draw(in: explosionRect!)
		}
	}

	func update() {
		explosionTicks += explosionLimit / 30
		let ds = explosionTicks > explosionLimit / 2 ?
			CGFloat(2 * (explosionLimit - explosionTicks)) :
			CGFloat(2 * explosionTicks)
		let size = 2 * ds
		explosionRect = NSMakeRect(position.x - ds, position.y - ds, size, size)
	}

	func isDone() -> Bool {
		return explosionTicks > explosionLimit
	}
	
}
