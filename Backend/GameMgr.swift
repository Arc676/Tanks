//
//  GameMgr.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 30/07/2017.
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

	func initialize(terrainType: TerrainType, players: [Tank], controller: ViewController) {
		terrain.generateNewTerrain(terrainType, height: UInt32(bounds.height), width: Int(bounds.width))
		self.players = players
		viewController = controller

		var i = 0
		for player in self.players {
			let pos = (i + 1) * 3
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

	func terminate() {
		gameTimer?.invalidate()
		viewController?.goToStore()
	}

	func gameOver() -> Bool {
		var stillAlive = 0
		for tank in players {
			if tank.hp > 0 {
				stillAlive++
			}
		}
		//if less than two players remain, the game is over (maybe everyone died)
		return stillAlive < 2
	}

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
