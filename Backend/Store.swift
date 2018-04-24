//
//  Store.swift
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

	let storeItems: [Item] = [
		Ammo("Missile", price: 10, radius: 20, damage: 80,
			 sound: NSSound(named: NSSound.Name("ex_small.wav"))!),
		Hailfire("Hailfire I", price: 500, radius: 15, damage: 60,
				 sound: NSSound(named: NSSound.Name("ex_small.wav"))!, projCount: 3),
		Ammo("Atom Bomb", price: 1000, radius: 60, damage: 1000,
			 sound: NSSound(named: NSSound.Name("ex_large.wav"))!),
		Hailfire("Hailfire II", price: 1500, radius: 20, damage: 80,
				 sound: NSSound(named: NSSound.Name("ex_small.wav"))!, projCount: 4),
		Ammo("Hydrogen Bomb", price: 5000, radius: 120, damage: 2000,
			 sound: NSSound(named: NSSound.Name("ex_large.wav"))!),
		Hailfire("Hailfire III", price: 7000, radius: 30, damage: 100,
				 sound: NSSound(named: NSSound.Name("ex_large.wav"))!, projCount: 6),
		Hailfire("Hailfire IV", price: 12000, radius: 50, damage: 500,
				 sound: NSSound(named: NSSound.Name("ex_large.wav"))!, projCount: 10),
		Airstrike("Airstrike", price: 9000, radius: 30, damage: 400,
				  sound: NSSound(named: NSSound.Name("ex_large.wav"))!),
		LaserStrike("Space Laser", price: 10000, radius: 40, damage: 1000,
					sound: NSSound(named: NSSound.Name("ex_large.wav"))!),
		Upgrade("Engine Efficiency", 1.1, price: 400, type: .ENGINE),
		Upgrade("Armor", 1.1, price: 600, type: .ARMOR),
		Upgrade("Extra Fuel", 20, price: 300, type: .START_FUEL),
		Upgrade("Hill Climbing", 1.2, price: 500, type: .HILL_CLIMB)
	]

	var viewController: ViewController?

	var players: [Tank]?
	var currentPlayer = -1
	var saveAIs = false

	static let upgradeColor = Color.blue
	static let targetedColor = Color.red
	static let untargetedColor = Color(red:0.00, green:0.51, blue:0.21, alpha:1.00)

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
		if 0 <= index && index < storeItems.count {
			players![currentPlayer].purchaseItem(storeItems[index])
		}
	}

	/**
	Save the current player to disk. To be overriden for each platform.
	*/
	func savePlayer() {}

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
				(players![currentPlayer] as! CCTank).makePurchases(storeItems)
				if saveAIs {
					savePlayer()
				}
				nextPlayer()
			}
		}
	}

}
