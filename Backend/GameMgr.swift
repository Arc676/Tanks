//
//  GameMgr.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 30/07/2017.
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
	typealias View = NSView
	typealias ViewController = GameViewController
#elseif os(iOS)
	import UIKit
	typealias View = UIView
#endif

/**
Platform independent backend manager for
tracking game data
*/
class GameMgr: View {

	//physics
	static let timeScaleFactor: CGFloat = 15

	//key codes for Q, W, PgUp, PgDn, arrow keys, space
	static let qKey: UInt16 = 12
	static let wKey: UInt16 = 13
	static let pgUpKey: UInt16 = 116
	static let pgDnKey: UInt16 = 121
	static let upArrow: UInt16 = 126
	static let downArrow: UInt16 = 125
	static let leftArrow: UInt16 = 123
	static let rightArrow: UInt16 = 124
	static let spaceBar: UInt16 = 49

	let relevantKeys: [UInt16] = [
		GameMgr.qKey,
		GameMgr.wKey,
		GameMgr.pgUpKey,
		GameMgr.pgDnKey,
		GameMgr.upArrow,
		GameMgr.downArrow,
		GameMgr.leftArrow,
		GameMgr.rightArrow,
		GameMgr.spaceBar
	]

	var terrain: Terrain = Terrain()
	var players: [Tank] = []

	//UI
	var playerNames: [NSAttributedString] = []
	var uiMarks: [NSAttributedString : NSPoint]?

	var activePlayer = 0
	var keyStates: [UInt16: Bool] = [:]

	var gameTimer: Timer?
	var viewController: ViewController?

	/**
	Initialize a new game with the given properties

	- parameters:
		- terrainType: The type of terrain for the map in the new game
		- players: The tanks involved in the game
		- controller: The view controller for the game
	*/
	func initialize(terrainType: TerrainType, players: [Tank]?, controller: ViewController) {
		terrain.generateNewTerrain(terrainType, height: UInt32(bounds.height), width: Int(bounds.width))
		viewController = controller

		if players != nil {
			self.players = players!
		}

		var i = 0
		for player in self.players {
			let pos = (i + 1) * 3
			player.reset()
			player.terrain = terrain
			player.tanks = self.players
			player.position = NSMakePoint(
				CGFloat(pos * terrain.chunkSize),
				terrain.terrainControlHeights[pos])

			playerNames.append(NSAttributedString(string: player.name!))

			i++
		}

		for key in relevantKeys {
			keyStates[key] = false
		}

		gameTimer = Timer.scheduledTimer(
			timeInterval: 1.0 / 60,
			target: self,
			selector: #selector(update),
			userInfo: nil,
			repeats: true)
	}

	/**
	End the game
	*/
	func terminate() {
		gameTimer?.invalidate()
		viewController?.goToStore()
	}

	/**
	Check whether the game has ended

	- returns:
	Whether the game is over i.e. less than two players remain
	(maybe everyone died)
	*/
	func gameOver() -> Bool {
		var stillAlive = 0
		for tank in players {
			if tank.hp > 0 {
				stillAlive++
			}
		}
		return stillAlive < 2
	}

	/**
	Update all entities in the game and check if the game
	is over
	*/
	@objc func update() {
		var i = 0
		for tank in players {
			if i == activePlayer {
				tank.update(keys: keyStates)
				if tank.turnEnded {
					tank.resetState()
					activePlayer = (activePlayer + 1) % players.count
					terrain.newWindSpeed()
				}
			} else {
				tank.passiveUpdate()
			}
			i++
		}
		needsDisplay = true
		if gameOver() {
			terminate()
		}
	}

	override func draw(_ rect: NSRect) {
		terrain.draw(rect)

		for tank in players {
			if tank.hp <= 0 {
				continue
			}
			tank.drawInRect(rect)
		}
	}

}
