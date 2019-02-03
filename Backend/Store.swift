//
//  Store.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017-9 Arc676/Alessandro Vinciguerra

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

#if os(OSX)
	import Cocoa
	typealias Color = NSColor
#elseif os(iOS)
	import UIKit
	typealias Color = UIColor
#endif

/**
Platform independent backend manager
for store data
*/
class Store: View {

	static let smallEx = NSSound(named: NSSound.Name("ex_small.wav"))!
	static let largeEx = NSSound(named: NSSound.Name("ex_large.wav"))!
	static let noSound = NSSound()

	static let saveSuccess = NSSound(named: NSSound.Name("success.wav"))!
	static let saveFailed = NSSound(named: NSSound.Name("failure.wav"))!

	// indices of various items to be purchased by computer controlled tanks
	let armorIndex = 16
	let targetingWeapons = 12

	let storeItems: [Item] = [
		// normal weapons
		Ammo("Missile", price: 10, radius: 10, damage: 80, sound: Store.smallEx),
		Ammo("Armor Piercing Shell", price: 20, radius: 20, damage: 180, sound: Store.smallEx),
		ShrapnelShot("Shrapnel Round", price: 50, radius: 30, damage: 50, sound: Store.smallEx),
		Hailfire("Hailfire I", price: 200, radius: 15, damage: 60, sound: Store.smallEx, projCount: 3),
		Ammo("Atom Bomb", price: 1000, radius: 60, damage: 1000, sound: Store.largeEx),
		Hailfire("Hailfire II", price: 500, radius: 20, damage: 80, sound: Store.smallEx, projCount: 4),
		LaserBeam("Laser Beam I", price: 600, radius: 0, damage: 800, ticks: 30, sound: Store.noSound),
		Ammo("Hydrogen Bomb", price: 1400, radius: 120, damage: 2000, sound: Store.largeEx),
		Hailfire("Hailfire III", price: 1500, radius: 30, damage: 100, sound: Store.largeEx, projCount: 6),
		LaserBeam("Laser Beam II", price: 1600, radius: 30, damage: 1000, ticks: 30, sound: Store.noSound),
		Hailfire("Hailfire IV", price: 1800, radius: 50, damage: 500, sound: Store.largeEx, projCount: 10),
		LaserBeam("Laser Beam III", price: 2000, radius: 40, damage: 1100, ticks: 60, sound: Store.noSound),

		// targeted weapons
		Airstrike("Airstrike I", price: 2000, radius: 30, damage: 400, sound: Store.largeEx, projCount: 5),
		Airstrike("Airstrike II", price: 3000, radius: 50, damage: 800, sound: Store.largeEx, projCount: 11),
		LaserStrike("Space Laser", price: 3200, radius: 40, damage: 1000, sound: Store.noSound),

		// upgrades
		Upgrade("Engine Efficiency", 1.1, price: 100, type: .ENGINE),
		Upgrade("Armor", 1.1, price: 200, type: .ARMOR),
		Upgrade("Extra Fuel", 20, price: 50, type: .START_FUEL),
		Upgrade("Hill Climbing", 1.2, price: 150, type: .HILL_CLIMB),

		// items
		RepairKit(price: 50),
		Teleport(price: 3000),
		Shield("Weak Shield", price: 100, dmgLimit: 50, color: Color.yellow),
		Shield("Medium Shield", price: 500, dmgLimit: 200, color: Color.green),
		Shield("Strong Shield", price: 1000, dmgLimit: 1000, color: Color.blue),
		Shield("Ultimate Shield", price: 3500, dmgLimit: 10000, color: Color.purple)
	]

	var viewController: ViewController?

	var players: [Tank]?
	var currentPlayer = -1

	/**
	Initialize the store view with the given game
	properties

	- parameters:
		- players: The entities in the game
		- viewController: The view controller for the game
	*/
	func initialize(_ players: [Tank], viewController: ViewController) {
		self.players = players
		self.viewController = viewController
		currentPlayer = -1
		nextPlayer()
	}

	/**
	Have a tank purchase an item at the given index (index is
	validated before allowing purchase)

	- parameters:
		- index: Index of the desired item to buy
	*/
	func purchaseItem(_ index: Int) {
		if players![currentPlayer] is CCTank {
			return
		}
		if 0 <= index && index < storeItems.count {
			players![currentPlayer].purchaseItem(storeItems[index])
		}
	}

	/**
	Save the current player to disk. To be overriden for each platform.

	- returns:
	Whether the save succeeded.
	*/
	func savePlayer() -> Bool {
		return false
	}

	/**
	Prepares the view for the next player or starts the next
	game is all players have made their purchases
	*/
	func nextPlayer() {
		if currentPlayer + 1 >= players!.count {
			viewController?.startGame()
		} else {
			currentPlayer++
			if players![currentPlayer] is CCTank {
				(players![currentPlayer] as! CCTank).makePurchases(self)
			}
		}
	}

}
