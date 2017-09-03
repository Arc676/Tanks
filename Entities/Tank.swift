//
//  Tank.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
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

enum AILevel: Int {
	case LOW
	case MED
	case HIGH
}

class Tank : NSObject {

	static let radian: Float = 0.0174532925

	//gameplay properties
	var hp = 100

	//firing properties
	var firepower = 50
	var cannonAngle: Float = 0

	//tank state
	var position: NSPoint = NSMakePoint(0, 0)
	var lastY: CGFloat = 0
	var fuel: Float = 100
	var money: Int = 0

	//turn properties
	var turnEnded = false
	var hasFired = false

	//tank properties
	var name: String?
	var tankColor: NSColor?
	var playerNum = 0
	var projectile: Projectile?
	var maxHillClimb: CGFloat = 1
	var engineEfficiency: Float = 1
	var startingFuel: Float = 100

	//environment
	var terrain: Terrain?
	var tanks: [Tank]?

	init(color: NSColor, pNum: Int, name: String) {
		tankColor = color
		playerNum = pNum
		self.name = name
	}

	func fireProjectile() {
		let vx: CGFloat = CGFloat(Double(firepower) * cos(Double(cannonAngle)))
		let vy: CGFloat = CGFloat(Double(firepower) * sin(Double(cannonAngle)))
		projectile = Projectile(terrain: terrain!, entities: tanks!, vx: vx, vy: vy, pos: position)

		hasFired = true
	}

	func takeDamage(_ dmg: Int) {
		hp -= dmg
	}

	func drawInRect(_ rect: NSRect) {
		//temporary, eventually there'll be a texture for the tank (maybe...?)
		tankColor?.set()
		NSRectFill(NSMakeRect(position.x - 10, position.y, 20, 10))

		//should be temporary, eventually there should be a texture (maybe...?)
		NSColor.black.set()
		var path = NSBezierPath(rect: NSMakeRect(0, -3, 20, 6))
		let transform = NSAffineTransform()
		transform.translateX(by: position.x, yBy: position.y + 8)
		transform.rotate(byRadians: CGFloat(cannonAngle))
		path = transform.transform(path)
		path.fill()

		//draw projectile, if present (optional types ftw :P)
		projectile?.drawInRect(rect)
	}

	func endTurn() {
		turnEnded = true
		projectile = nil
	}

	func resetState() {
		turnEnded = false
		hasFired = false
	}

	func passiveUpdate() {
		if hp <= 0 {
			endTurn()
			return
		}
		lastY = position.y
		if !terrain!.terrainPath!.contains(position) {
			position.y -= 1
		}
		if position.y <= 0 {
			hp = 0
		}
		if projectile?.hasImpacted ?? false {
			endTurn()
		}
	}

	func update(keys: [UInt16: Bool]) {
		if hp <= 0 {
			endTurn()
			return
		}
		projectile?.update()
		passiveUpdate()
	}

	func move(_ vector: CGFloat) {
		let direction: CGFloat = vector < 0 ? -1 : 1
		if position.x + direction <= 0 ||
			position.x + direction >= CGFloat(terrain!.terrainWidth) ||
			fuel <= 0 {
			return
		}
		var x: Int
		if direction < 0 {
			x = Int(ceil(position.x / CGFloat(terrain!.chunkSize)))
		} else {
			x = Int(floor(position.x / CGFloat(terrain!.chunkSize)))
		}
		let y1 = terrain!.terrainControlHeights[x]
		let y2 = terrain!.terrainControlHeights[x + Int(direction)]
		let gradient = (y2 - y1) / CGFloat(terrain!.chunkSize)
		if gradient < maxHillClimb {
			fuel -= Float(abs(vector)) * engineEfficiency
			position.x += vector
			position.y += gradient * vector
		}
	}

}
