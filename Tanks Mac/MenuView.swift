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
	var players: [Tank?] = [
		nil, nil, nil, nil
	]

	//player 1
	@IBOutlet weak var p1name: NSTextField!
	@IBOutlet weak var p1color: NSColorWell!
	@IBOutlet weak var p1isAI: NSButton!
	@IBOutlet weak var p1AILvl: NSSegmentedControl!
	@IBOutlet weak var p1Load: NSButton!
	@IBOutlet weak var p1Unload: NSButton!

	//player 2
	@IBOutlet weak var p2name: NSTextField!
	@IBOutlet weak var p2color: NSColorWell!
	@IBOutlet weak var p2isAI: NSButton!
	@IBOutlet weak var p2AILvl: NSSegmentedControl!
	@IBOutlet weak var p2Load: NSButton!
	@IBOutlet weak var p2Unload: NSButton!

	//player 3
	@IBOutlet weak var enableP3: NSButton!
	@IBOutlet weak var p3name: NSTextField!
	@IBOutlet weak var p3color: NSColorWell!
	@IBOutlet weak var p3isAI: NSButton!
	@IBOutlet weak var p3AILvl: NSSegmentedControl!
	@IBOutlet weak var p3Load: NSButton!
	@IBOutlet weak var p3Unload: NSButton!

	//player 4
	@IBOutlet weak var enableP4: NSButton!
	@IBOutlet weak var p4name: NSTextField!
	@IBOutlet weak var p4color: NSColorWell!
	@IBOutlet weak var p4isAI: NSButton!
	@IBOutlet weak var p4AILvl: NSSegmentedControl!
	@IBOutlet weak var p4Load: NSButton!
	@IBOutlet weak var p4Unload: NSButton!

	// Military code words for letters
	// (random names if not provided)
	static let nameCount = 26
	let names = [
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
	var nameUsed = [Bool](repeating: false, count: MenuView.nameCount)

	/**
	Toggle whether a player is enabled and enable or
	disable the corresponding UI elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func togglePlayer(_ sender: NSButton) {
		let state = sender.state == NSControl.StateValue.on
		if sender == enableP3 {
			let isLoaded = players[2] != nil
			p3name.isEnabled = state && !isLoaded
			p3color.isEnabled = state
			p3isAI.isEnabled = state
			p3AILvl.isEnabled = state && p3isAI.state == NSControl.StateValue.on
			p3Load.isEnabled = state && !isLoaded
			p3Unload.isEnabled = state && isLoaded
		} else {
			let isLoaded = players[3] != nil
			p4name.isEnabled = state && !isLoaded
			p4color.isEnabled = state
			p4isAI.isEnabled = state
			p4AILvl.isEnabled = state && p4isAI.state == NSControl.StateValue.on
			p4Load.isEnabled = state && !isLoaded
			p4Unload.isEnabled = state && isLoaded
		}
	}

	/**
	Toggle whether a player should be computer controlled
	and enable or disable UI elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func toggleAI(_ sender: NSButton) {
		let state = sender.state == NSControl.StateValue.on
		if sender == p1isAI {
			p1AILvl.isEnabled = state
		} else if sender == p2isAI {
			p2AILvl.isEnabled = state
		} else if sender == p3isAI {
			p3AILvl.isEnabled = state
		} else {
			p4AILvl.isEnabled = state
		}
	}

	/**
	Indicate that a tank should be loaded from a
	file when the game starts, ask for the file from
	which the player should be loaded, and disable UI
	elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func loadFromFile(_ sender: NSButton) {
		var failed = false
		let panel = NSOpenPanel()
		if panel.runModal() == NSApplication.ModalResponse.OK {
			do {
				let data = try Data(contentsOf: panel.url!)
				if let tank = NSKeyedUnarchiver.unarchiveObject(with: data) as? Tank {
					if sender == p1Load {
						players[0] = tank
						p1name.stringValue = "(Player to be loaded from file)"
						p1name.isEnabled = false
						p1Unload.isEnabled = true
						p1Load.isEnabled = false
					} else if sender == p2Load {
						players[1] = tank
						p2name.stringValue = "(Player to be loaded from file)"
						p2name.isEnabled = false
						p2Unload.isEnabled = true
						p2Load.isEnabled = false
					} else if sender == p3Load {
						players[2] = tank
						p3name.stringValue = "(Player to be loaded from file)"
						p3name.isEnabled = false
						p3Unload.isEnabled = true
						p3Load.isEnabled = false
					} else {
						players[3] = tank
						p4name.stringValue = "(Player to be loaded from file)"
						p4name.isEnabled = false
						p4Unload.isEnabled = true
						p4Load.isEnabled = false
					}
				} else {
					failed = true
				}
			} catch {
				failed = true
			}
			if failed {
				let alert = NSAlert()
				alert.messageText = "Failed to load tank data"
				alert.runModal()
			}
		}
	}

	/**
	Indicate that a tank previously designated to be
	loaded from a file should not be loaded from a file
	and enable UI elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func unloadFile(_ sender: NSButton) {
		if sender == p1Unload {
			players[0] = nil
			p1name.stringValue = ""
			p1name.isEnabled = true
			p1Unload.isEnabled = false
			p1Load.isEnabled = true
		} else if sender == p2Unload {
			players[1] = nil
			p2name.stringValue = ""
			p2name.isEnabled = true
			p2Unload.isEnabled = false
			p2Load.isEnabled = true
		} else if sender == p3Unload {
			players[2] = nil
			p3name.stringValue = ""
			p3name.isEnabled = true
			p3Unload.isEnabled = false
			p3Load.isEnabled = true
		} else {
			players[3] = nil
			p4name.stringValue = ""
			p4name.isEnabled = true
			p4Unload.isEnabled = false
			p4Load.isEnabled = true
		}
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
		if players[0] == nil {
			players[0] = createTank(p1name.stringValue, p1color.color, isCC: p1isAI, aiLvl: p1AILvl)
		}
		if players[1] == nil {
			players[1] = createTank(p2name.stringValue, p2color.color, isCC: p2isAI, aiLvl: p2AILvl)
		}
		if p3name.isEnabled {
			if players[2] == nil {
				players[2] = createTank(p3name.stringValue, p3color.color, isCC: p3isAI, aiLvl: p3AILvl)
			}
		} else {
			players[2] = nil
		}
		if p4name.isEnabled {
			if players[3] == nil {
				players[3] = createTank(p4name.stringValue, p4color.color, isCC: p4isAI, aiLvl: p4AILvl)
			}
		} else {
			players[3] = nil
		}
		let compacted = players.compactMap{ $0 }
		var pNum = 1
		for tank in compacted {
			tank.playerNum = pNum
			pNum++
		}
		viewController?.initialize(terrainType: terrainType)
		viewController?.startGame(compacted)
	}

	/**
	Create a new tank with the given properties and data
	from UI elements

	- parameters:
		- givenName: The name to assign to the tank
		- color: The color of the tank
		- pNum: The player number to assign to the tank
		- isCC: The checkbox indicating whether the tank is to be computer controlled
		- aiLvl: The segmented control indicating the desired AI level if the tank is
		to be computer controlled

	- returns:
	A tank with the specified properties
	*/
	private func createTank(_ givenName: String, _ color: NSColor, isCC: NSButton, aiLvl: NSSegmentedControl) -> Tank {
		let name = givenName == "" ? getRandomName() : givenName
		if (isCC.state == NSControl.StateValue.on) {
			return CCTank(color: color, pNum: 0, lvl: AILevel(rawValue: aiLvl.selectedSegment)!, name: name)
		} else {
			return Player(color: color, pNum: 0, name: name)
		}
	}

	/**
	Pick a random name that hasn't already been used by another tank
	*/
	private func getRandomName() -> String {
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
