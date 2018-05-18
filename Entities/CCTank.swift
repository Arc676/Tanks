//
//  CCTank.swift
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

import Cocoa

/**
Computer controlled tank object
*/
class CCTank : Tank {

	var aiLevel: AILevel! = .LOW
	var aiStyle: AIStyle! = .DEFENSIVE

	var target: Tank?

	var targetAngle: Float = 0
	var targetFirepower: Int = 0

	var needsRecalc = true

	/**
	Create a new computer controlled tank

	- parameters:
		- color: Color of tank
		- pNum: Player number assigned to tank
		- lvl: Level of AI to control this tank
		- name: Name assigned to tank
	*/
	init(color: NSColor, pNum: Int, lvl: AILevel, name: String) {
		aiLevel = lvl
		super.init(color: color, pNum: pNum, name: name)
	}

	required init?(coder aDecoder: NSCoder) {
		aiLevel = aDecoder.decodeObject(forKey: "AILvl") as! AILevel
		aiStyle = aDecoder.decodeObject(forKey: "AIStyle") as! AIStyle
		super.init(coder: aDecoder)
	}

	override func encode(with aCoder: NSCoder) {
		aCoder.encode(aiLevel, forKey: "AILvl")
		aCoder.encode(aiStyle, forKey: "AIStyle")
		super.encode(with: aCoder)
	}

	/**
	Return the uncertainty in aiming angle based on the
	desired level of difficulty for the AI

	- parameters:
		- lvl: The AI level
		- rad: Whether the result should be in radians

	- returns:
	The corresponding uncertainty in firing angle for the AI level
	*/
	private static func uncertaintyForLevel(_ lvl: AILevel, rad: Bool) -> Float {
		let k = rad ? Tank.radian : 1
		switch lvl {
		case .LOW:
			return 10 * k
		case .MED:
			return 5 * k
		case .HIGH:
			return 0
		}
	}

	/**
	Have the computer decide which items to purchase
	given a selection of items

	- parameters:
		- items: The available items for purchase
	*/
	func makePurchases(_ store: Store) {
		// AIs on LOW don't buy items
		if aiLevel.rawValue > AILevel.LOW.rawValue {
			// only HIGH level DEFENSIVE AIs buy armor upgrades
			if aiLevel == .HIGH &&
				aiStyle == .DEFENSIVE {
				purchaseItem(store.storeItems[store.armorIndex])
			}
			// AGGRESSIVE AIs buy all the top projectile-based weapons
			if aiStyle == .AGGRESSIVE {
				for i in (0..<store.targetingWeapons).reversed() {
					let item = store.storeItems[i] as! Ammo
					if !item.isProjectile {
						continue
					}
					while money > item.price {
						purchaseItem(item)
					}
				}
			} else {
				//
			}
		}
	}

	/**
	Choose a new target to the tank to fire at. This should be called
	when the tank doesn't have a target or when the target dies.
	*/
	func chooseNewTarget() {
		var possibleTargets = tanks!.filter { $0.hp > 0 && $0.playerNum != playerNum }
		if possibleTargets.count == 0 {
			return;
		}
		target = possibleTargets[Int(arc4random_uniform(UInt32(possibleTargets.count)))]

		recalculate(tx: target!.position.x, ty: target!.position.y, a: CGFloat(terrain!.windAcceleration))
	}

	/**
	Recalculate the required firing angle and firepower to hit the
	target location on the map

	- parameters:
		- tx: X coordinate of target
		- ty: Y coordinate of target
		- a: Wind acceleration
	*/
	private func recalculate(tx: CGFloat, ty: CGFloat, a: CGFloat) {
		let x = tx - position.x
		let y = ty - position.y

		let b = (y / -x) - x
		var a1: CGFloat = 0.01

		var range: CountableClosedRange<Int>?
		if x < 0 {
			range = (Int(tx) / terrain!.chunkSize + 1)...(Int(position.x) / terrain!.chunkSize - 1)
		} else {
			range = (Int(position.x) / terrain!.chunkSize + 1)...(Int(tx) / terrain!.chunkSize - 1)
		}

		for i in range! {
			let xc = CGFloat(i * terrain!.chunkSize) - position.x
			let h = terrain!.terrainControlHeights[i] - position.y
			if -a1 * xc * (xc + b) < h {
				a1 = -(h + 10) / (xc * (xc + b))
			}
		}

		targetAngle = Float(atan(-a1 * b))
		if x < 0 {
			targetAngle += .pi
		}

		let s = CGFloat(sin(targetAngle))
		let c = CGFloat(cos(targetAngle))
		let sc = s * c

		let den1 = 2 * a * (x * s * s - y * sc)
		let den2 = 2 * 9.81 * (x * sc - y * c * c)

		if den1 + den2 < 0 {
			targetFirepower = 100
		} else {
			targetFirepower = abs(Int(round((a * y + 9.81 * x) / sqrt(den1 + den2))))
		}

		targetAngle += Float(arc4random_uniform(1000)) / 1000 * CCTank.uncertaintyForLevel(aiLevel, rad: true)
		targetFirepower += Int(arc4random_uniform(UInt32(CCTank.uncertaintyForLevel(aiLevel, rad: false))))

		assert(targetAngle >= 0 && targetAngle <= .pi)
		if targetFirepower > 100 {
			Swift.print(targetFirepower)
		}

		needsRecalc = false
	}

	override func fireProjectile() {
		super.fireProjectile()
		needsRecalc = true
	}

	override func update(keys: [UInt16 : Bool]) {
		super.update(keys: keys)
		//skip update if the turn is over, or a shot has already been taken
		if turnEnded || hasFired {
			return
		} else if !hasFired {
			//if the tank has not yet fired, wait
			//for all surviving tanks to stop falling
			if tanks!.filter({ $0.hp > 0 && $0.isFalling }).count > 0 {
				return
			}
		}
		//if no target chosen or previous target is dead, retarget
		if target == nil || target!.hp <= 0 {
			chooseNewTarget()
		}
		//needs to recalculate firepower and cannon angle?
		if needsRecalc {
			recalculate(tx: target!.position.x, ty: target!.position.y, a: CGFloat(terrain!.windAcceleration))
		}

		if abs(targetAngle - cannonAngle) <= Tank.radian * 2 {
			cannonAngle = targetAngle
			if firepower == targetFirepower {
				fireProjectile()
			} else {
				if firepower < targetFirepower {
					firepower++
				} else {
					firepower--
				}
			}
		} else {
			if cannonAngle < targetAngle {
				rotate(Tank.radian / 2)
			} else {
				rotate(-Tank.radian / 2)
			}
		}
	}
	
}
