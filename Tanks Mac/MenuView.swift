//
//  MenuView.swift
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
View for the main menu of the game
*/
class MenuView : NSView {

	var viewController: GameViewController?

	@IBOutlet weak var terrainSelection: NSButton!
	var terrainType: TerrainType = .RANDOM

	@IBOutlet weak var player1: TankCreator!
	@IBOutlet weak var player2: TankCreator!
	@IBOutlet weak var player3: TankCreator!
	@IBOutlet weak var player4: TankCreator!
	
	// Military code words for letters
	// (random names if not provided)
	static let nameCount = 26
	static let names = [
		"Alpha",
		"Bravo",
		"Charlie",
		"Delta",
		"Echo",
		"Foxtrot",
		"Golf",
		"Hotel",
		"India",
		"Juliet",
		"Kilo",
		"Lima",
		"Mike",
		"November",
		"Oscar",
		"Papa",
		"Quebec",
		"Romeo",
		"Sierra",
		"Tango",
		"Uniform",
		"Victor",
		"Whiskey",
		"X-ray",
		"Yankee",
		"Zulu"
	]
	static var nameUsed = [Bool](repeating: false, count: MenuView.nameCount)

	override func awakeFromNib() {
		super.awakeFromNib()
		// initialize tank setup UI
		// default configuration is for Player 1, so skip P1
		player2.setState("Player 2", color: NSColor.red, canDisable: false)
		player3.setState("Player 3", color: NSColor.green, canDisable: true)
		player4.setState("Player 4", color: NSColor.yellow, canDisable: true)
	}

	/**
	Change the desired terrain type for the game

	- parameters:
		- sender: Radio button clicked
	*/
	@IBAction func selectTerrain(_ sender: NSButton) {
		switch sender.title {
		case "Desert":
			terrainType = .DESERT
		case "Plains":
			terrainType = .FLATLAND
		case "Hills":
			terrainType = .HILLS
		case "Random":
			terrainType = .RANDOM
		default:
			break
		}
	}

	/**
	Start the game

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func startGame(_ sender: Any) {
		let players = [
			player1.getTank(),
			player2.getTank(),
			player3.getTank(),
			player4.getTank()
			].compactMap{ $0 }
		var pNum = 1
		for tank in players {
			tank.playerNum = pNum
			pNum++
		}
		viewController?.initialize(terrainType: terrainType)
		viewController?.startGame(players)
	}

	@IBAction func loadMultipleTanks(_ sender: Any) {
		let panel = NSOpenPanel()
		panel.allowsMultipleSelection = true
		if panel.runModal() == NSApplication.ModalResponse.OK {
			var i = 0
			for url in panel.urls {
				switch (i) {
				case 0:
					player1.loadTank(from: url)
				case 1:
					player2.loadTank(from: url)
				case 2:
					player3.loadTank(from: url)
				case 3:
					player4.loadTank(from: url)
				default:
					break
				}
				i++
			}
		}
	}

	/**
	Gets a list of URLs indicating whence the tanks were loaded

	- returns:
	A list containing optional URLs indicating the original save location of each tank, if any
	*/
	func getPaths() -> [URL?] {
		return [
			player1.tankWasLoadedFromDisk(),
			player2.tankWasLoadedFromDisk(),
			player3.tankWasLoadedFromDisk(),
			player4.tankWasLoadedFromDisk()
		]
	}

	/**
	Pick a random name that hasn't already been used by another tank

	- returns:
	A random, as of yet unused codename
	*/
	static func getRandomName() -> String {
		var keyIndex = Int(arc4random_uniform(UInt32(MenuView.nameCount)))
		while nameUsed[keyIndex] {
			keyIndex = (keyIndex + 1) % MenuView.nameCount
		}
		nameUsed[keyIndex] = true
		return names[keyIndex]
	}

	/**
	Quit the application

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func quitGame(_ sender: Any) {
		viewController?.quit(sender)
	}
	
}
