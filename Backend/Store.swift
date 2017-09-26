//
//  Store.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
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

#if os(OSX)
	import Cocoa
#elseif os(iOS)
	import UIKit
#endif

class Store: View {

	let storeItems: [Item] = [
		Ammo("Missile", price: 10, radius: 20, damage: 30),
		Ammo("Atom Bomb", price: 1000, radius: 60, damage: 100),
		Ammo("Hydrogen Bomb", price: 50000, radius: 120, damage: 200)
	]

	var viewController: ViewController?

	var players: [Tank]?
	var currentPlayer = -1

	func initialize(_ players: [Tank], viewController: ViewController) {
		self.players = players
		self.viewController = viewController
		currentPlayer = -1
		nextPlayer()
	}

	func purchaseItem(_ index: Int) {
		if index < storeItems.count {
			players![index].purchaseItem(storeItems[index])
		}
	}

	func nextPlayer() {
		if currentPlayer + 1 >= players!.count {
			viewController?.startGame()
		} else {
			currentPlayer += 1
			if players![currentPlayer] is CCTank {
				(players![currentPlayer] as! CCTank).makePurchases(storeItems)
				nextPlayer()
			}
		}
	}

}
