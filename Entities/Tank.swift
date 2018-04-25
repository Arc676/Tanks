//
//  Tank.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
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
Represents the AI "intelligence" level
*/
enum AILevel: Int {
	case LOW
	case MED
	case HIGH
}

/**
Represents the property that will be
affected by an upgrade
*/
enum UpgradeType: Int {
	case HILL_CLIMB
	case ENGINE
	case START_FUEL
	case ARMOR
}

/**
Tank representation that can be archived and
written to disk
*/
class Tank : NSObject, NSCoding {

	static let radian: Float = 0.0174532925

	static let firingSound = NSSound(named: NSSound.Name("firing.mp3"))!
	static let rotateSound = NSSound(named: NSSound.Name("rotate.wav"))!

	//gameplay properties
	var hp: CGFloat = 100
	var fuel: CGFloat = 100
	var money: Int = 0
	var score: Int = 0

	//combat mechanics
	var selectedWeapon = 0
	var weapons: [Ammo] = [
		Ammo("Tank Shell", price: 0, radius: 20, damage: 50, sound: Store.smallEx)
	]
	var weaponCount: [String : Int] = [:]
	var upgradeCount: [Int] = [Int](repeating: 0, count: 4)

	//physics
	var maxHillClimb: CGFloat = 1
	var engineEfficiency: CGFloat = 1
	var startingFuel: CGFloat = 100
	var armor: CGFloat = 1

	//firing properties
	var firepower = 50
	var cannonAngle: Float = 0

	//tank state
	var position: NSPoint = NSMakePoint(0, 0)
	var lastY: CGFloat = 0
	var turnEnded = false
	var hasFired = false
	var isTargeting = false

	//tank properties
	var name: String?
	var tankColor: NSColor?
	var playerNum = 0
	var selectedAmmo: Ammo?

	//environment
	var terrain: Terrain?
	var tanks: [Tank]?

	/**
	Create a new Tank object

	- parameters:
		- color: Color of tank
		- pNum: The player number assigned to the tank
		- name: The name assigned to the tank
	*/
	init(color: NSColor, pNum: Int, name: String) {
		tankColor = color
		playerNum = pNum
		self.name = name
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(money, forKey: "Money")
		aCoder.encode(score, forKey: "Score")
		aCoder.encode(weapons, forKey: "Weapons")
		aCoder.encode(weaponCount, forKey: "WeaponCount")
		aCoder.encode(upgradeCount, forKey: "UpgradeCount")
		aCoder.encode(maxHillClimb, forKey: "MaxHillClimb")
		aCoder.encode(engineEfficiency, forKey: "EngineEfficiency")
		aCoder.encode(startingFuel, forKey: "StartingFuel")
		aCoder.encode(armor, forKey: "Armor")
		aCoder.encode(name, forKey: "Name")
		aCoder.encode(tankColor, forKey: "Color")
	}

	required init?(coder aDecoder: NSCoder) {
		money = aDecoder.decodeInteger(forKey: "Money")
		score = aDecoder.decodeInteger(forKey: "Score")
		weapons = aDecoder.decodeObject(forKey: "Weapons") as! [Ammo]
		weaponCount = aDecoder.decodeObject(forKey: "WeaponCount") as! [String : Int]
		upgradeCount = aDecoder.decodeObject(forKey: "UpgradeCount") as! [Int]
		maxHillClimb = aDecoder.decodeObject(forKey: "MaxHillClimb") as! CGFloat
		engineEfficiency = aDecoder.decodeObject(forKey: "EngineEfficiency") as! CGFloat
		startingFuel = aDecoder.decodeObject(forKey: "StartingFuel") as! CGFloat
		armor = aDecoder.decodeObject(forKey: "Armor") as! CGFloat
		name = aDecoder.decodeObject(forKey: "Name") as? String
		tankColor = aDecoder.decodeObject(forKey: "Color") as? NSColor
	}

	/**
	Reset the tank to it's pre-game state
	*/
	func reset() {
		hp = 100
		fuel = startingFuel
	}

	/**
	Fires the currently selected weapon using the current
	firing properties
	*/
	func fireProjectile(at target: NSPoint) {
		selectedAmmo = weapons[selectedWeapon]
		selectedAmmo?.fire(angle: cannonAngle,
						 firepower: firepower,
						 position: target,
						 terrain: terrain!,
						 tanks: tanks!,
						 src: playerNum - 1)

		if !selectedAmmo!.hasSound {
			GameMgr.playSound(Tank.firingSound)
		}

		let name = selectedAmmo!.name
		if name != "Tank Shell" {
			weaponCount[name]! -= 1
			if weaponCount[name]! == 0 {
				weaponCount.removeValue(forKey: name)
				weapons.remove(at: selectedWeapon)
				selectedWeapon = 0
			}
		}
		hasFired = true
		isTargeting = false
	}

	/**
	Utility function for fireProjectile for firing non-targetable
	weapons
	*/
	func fireProjectile() {
		if weapons[selectedWeapon].isTargeted {
			isTargeting = true
		} else {
			fireProjectile(at: position)
		}
	}

	/**
	Selects the previous available weapon, looping back if necessary
	*/
	func selectPreviousWeapon() {
		selectedWeapon -= 1
		if selectedWeapon < 0 {
			selectedWeapon = weapons.count - 1
		} else {
			selectedWeapon %= weapons.count
		}
	}

	/**
	Selects the next available weapon, looping back if necessary
	*/
	func selectNextWeapon() {
		selectedWeapon = (selectedWeapon + 1) % weapons.count
	}

	/**
	Reduce HP by damage taken, reduced by a factor equal
	to the tank's armor

	- parameters:
		- dmg: Damage dealt by ammunition
	*/
	func takeDamage(_ dmg: CGFloat) {
		hp -= dmg / armor
	}

	/**
	Draws the tank given the rectangle of the view

	- parameters:
		- rect: The view rectangle
	*/
	func drawInRect(_ rect: NSRect) {
		tankColor?.set()
		tankRect().fill()

		NSColor.black.set()

		// the origin of the rectangle is set so that the rotation
		// transformation causes the barrel to rotate about its
		// supposed mount point on the tank
		var path = NSBezierPath(rect: NSMakeRect(0, -3, 20, 6))
		let transform = NSAffineTransform()
		// the Y coordinate is translated by 8 and not 10 for
		// aesthetic reasons
		transform.translateX(by: position.x, yBy: position.y + 8)
		transform.rotate(byRadians: CGFloat(cannonAngle))
		path = transform.transform(path)
		path.fill()

		//draw projectiles, if present
		selectedAmmo?.drawInRect(rect)
	}

	/**
	Create an NSRect representing the bounds of the tank where the
	position of the tank corresponds to the center of the bottom edge
	of the rectangle

	- returns:
	The NSRect object whose size and position corresponds
	to the tank in the world
	*/
	func tankRect() -> NSRect {
		return NSMakeRect(position.x - 10, position.y, 20, 10)
	}

	/**
	Determine whether a given point is within the tank
	(for collision detection)

	- parameters:
	- point: The relevant point
	*/
	func hitTank(_ point: NSPoint) -> Bool {
		return NSPointInRect(point, tankRect())
	}

	/**
	Indicate that the tank's turn has ended
	*/
	func endTurn() {
		turnEnded = true
		selectedAmmo?.reset()
	}

	/**
	Reset the tank to it's pre-turn state
	*/
	func resetState() {
		selectedAmmo = nil
		turnEnded = false
		hasFired = false
	}

	/**
	Update the tank based on the environment while the tank
	cannot modify its state
	*/
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
		if selectedAmmo?.invalidated() ?? false {
			endTurn()
		}
	}

	/**
	Update the tank based on user input while the tank
	is allowed to alter its state

	- parameters:
		- keys: A dictionary indicating which keys are pressed
	*/
	func update(keys: [UInt16: Bool]) {
		if hp <= 0 {
			endTurn()
			return
		}
		selectedAmmo?.update()
		passiveUpdate()
	}

	/**
	Move the tank by the given distance

	- parameters:
		- vector: Distance to move
	*/
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
			fuel -= CGFloat(abs(vector)) / engineEfficiency
			position.x += vector
			position.y += gradient * abs(vector)
		}
	}

	/**
	Rotate the tank cannon by the given angle

	- parameters:
		- angle: Angle by which to rotate (in degrees)
	*/
	func rotate(_ angle: Float) {
		if !Tank.rotateSound.isPlaying {
			GameMgr.playSound(Tank.rotateSound)
		}
		cannonAngle += angle
		if cannonAngle < 0 {
			cannonAngle = 0
		} else if cannonAngle > Float.pi {
			cannonAngle = Float.pi
		}
	}

	/**
	Attempt to purchase an item

	- parameters:
		- item: The Item object to purchase
	*/
	func purchaseItem(_ item: Item) {
		if money >= item.price {
			money -= item.price
			if item is Ammo {
				if !weapons.contains(where: { element in
					return element.name == item.name
				}) {
					weapons.append(item as! Ammo)
				}
				weaponCount[item.name] = (weaponCount[item.name] ?? 0) + 1
			} else if item is Upgrade {
				let upgrade = item as! Upgrade
				switch upgrade.type {
				case .ARMOR:
					armor *= upgrade.upgradeQty
				case .ENGINE:
					engineEfficiency *= upgrade.upgradeQty
				case .HILL_CLIMB:
					maxHillClimb *= upgrade.upgradeQty
				case .START_FUEL:
					startingFuel += upgrade.upgradeQty
				}
				upgradeCount[upgrade.type.rawValue]++
			}
		}
	}

}
