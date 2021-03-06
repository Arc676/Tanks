//
//  GameMgr.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 30/07/2017.
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

	//key codes for Q, W, PgUp, PgDn, arrow keys, space, ESC
	static let qKey: UInt16 = 12
	static let wKey: UInt16 = 13
	static let pgUpKey: UInt16 = 116
	static let pgDnKey: UInt16 = 121
	static let upArrow: UInt16 = 126
	static let downArrow: UInt16 = 125
	static let leftArrow: UInt16 = 123
	static let rightArrow: UInt16 = 124
	static let spaceBar: UInt16 = 49
	static let escKey: UInt16 = 53

	let relevantKeys: [UInt16] = [
		GameMgr.qKey,
		GameMgr.wKey,
		GameMgr.pgUpKey,
		GameMgr.pgDnKey,
		GameMgr.upArrow,
		GameMgr.downArrow,
		GameMgr.leftArrow,
		GameMgr.rightArrow,
		GameMgr.spaceBar,
		GameMgr.escKey
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

	//Game settings
	static var enableSFX = true //static for access within GameMgr.playSound
	var drawDeclared = false

	/**
	Initialize a new game with the given properties

	- parameters:
		- terrainType: The type of terrain for the map in the new game
		- players: The tanks involved in the game
		- controller: The view controller for the game
	*/
	func initialize(terrainType: TerrainType, players: [Tank]?, controller: ViewController) {
		drawDeclared = false
		activePlayer = 0
		terrain.generateNewTerrain(terrainType, height: UInt32(bounds.height), width: Int(bounds.width))
		viewController = controller
		playerNames.removeAll()

		if players != nil {
			self.players = players!
		}

		// shuffle starting positions so players don't always spawn in the same place
		var positions: [Int] = []
		for _ in 0..<self.players.count {
			let pos = Int(arc4random_uniform(UInt32(terrain.pointCount - 7))) + 4
			if arc4random_uniform(100) < 50 {
				positions.append(pos)
			} else {
				positions.insert(pos, at: 0)
			}
		}

		for player in self.players {
			let pos = positions.popLast()!
			player.reset()
			player.terrain = terrain
			player.tanks = self.players
			player.position = NSMakePoint(
				CGFloat(pos * terrain.chunkSize),
				terrain.terrainControlHeights[pos])

			playerNames.append(NSAttributedString(string: player.name))
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
	Check whether the game has ended by checking if less
	than two players remain (maybe everyone died) or if
	a draw has been declared by the user

	- returns:
	Whether the game is over
	*/
	func gameOver() -> Bool {
		if drawDeclared {
			return true
		}
		let survivors = players.filter{ $0.hp > 0 }
		if survivors.count < 2 {
			return true
		}
		for i in 1..<survivors.count {
			if !survivors[0].isTeammate(survivors[i]) {
				return false
			}
		}
		return true
	}

	/**
	Declares the current game to be a draw and ends the
	current tank's turn
	*/
	func drawGame() {
		drawDeclared = true
		players[activePlayer].endTurn()
		for player in players.filter({ $0.hp > 0}) {
			player.score += 100;
			player.money += 100;
		}
	}

	/**
	Update all entities in the game and check if the game
	is over
	*/
	@objc func update() {
		var turnEnded = false
		var i = 0
		for tank in players {
			if i == activePlayer {
				tank.update(keys: keyStates)
				if tank.turnEnded {
					turnEnded = true
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
		if turnEnded && gameOver() {
			terminate()
		}
		terrain.update()
	}

	/**
	Utility function for playing sounds; only plays sound
	if sound effects are enabled

	- parameters:
		- sound: The sound to play
	*/
	static func playSound(_ sound: NSSound, copy: Bool = false) {
		if GameMgr.enableSFX {
			if copy {
				(sound.copy() as! NSSound).play()
			} else {
				sound.play()
			}
		}
	}

	override func draw(_ rect: NSRect) {
		terrain.draw(rect)

		for tank in players {
			tank.drawInRect(rect)
		}
	}

}
