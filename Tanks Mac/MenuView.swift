//
//  MenuView.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 25/07/2017.
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

import Cocoa

class MenuView : NSView {

	var viewController: GameViewController?

	@IBOutlet weak var terrainSelection: NSButton!
	var terrainType: TerrainType = .RANDOM

	//player 1
	@IBOutlet weak var p1name: NSTextField!
	@IBOutlet weak var p1color: NSColorWell!
	@IBOutlet weak var p1isAI: NSButton!
	@IBOutlet weak var p1AILvl: NSSegmentedControl!

	//player 2
	@IBOutlet weak var p2name: NSTextField!
	@IBOutlet weak var p2color: NSColorWell!
	@IBOutlet weak var p2isAI: NSButton!
	@IBOutlet weak var p2AILvl: NSSegmentedControl!

	//player 3
	@IBOutlet weak var p3name: NSTextField!
	@IBOutlet weak var p3color: NSColorWell!
	@IBOutlet weak var p3isAI: NSButton!
	@IBOutlet weak var p3AILvl: NSSegmentedControl!

	//player 4
	@IBOutlet weak var p4name: NSTextField!
	@IBOutlet weak var p4color: NSColorWell!
	@IBOutlet weak var p4isAI: NSButton!
	@IBOutlet weak var p4AILvl: NSSegmentedControl!

	@IBAction func toggleP3(_ sender: NSButton) {
		let state = sender.state == NSOnState
		p3name.isEnabled = state
		p3color.isEnabled = state
		p3isAI.isEnabled = state
	}

	@IBAction func toggleP3AI(_ sender: NSButton) {
		p3AILvl.isEnabled = sender.state == NSOnState
	}

	@IBAction func toggleP4(_ sender: NSButton) {
		let state = sender.state == NSOnState
		p4name.isEnabled = state
		p4color.isEnabled = state
		p4isAI.isEnabled = state
	}

	@IBAction func toggleP4AI(_ sender: NSButton) {
		p4AILvl.isEnabled = sender.state == NSOnState
	}

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

	@IBAction func startGame(_ sender: Any) {
		var players: [Tank] = []
		players.append(createTank(p1name.stringValue, p1color.color, 1, isCC: p1isAI, aiLvl: p1AILvl))
		players.append(createTank(p2name.stringValue, p2color.color, 2, isCC: p2isAI, aiLvl: p2AILvl))
		if (p3name.isEnabled) {
			players.append(createTank(p3name.stringValue, p3color.color, 3, isCC: p3isAI, aiLvl: p3AILvl))
		}
		if (p4name.isEnabled) {
			players.append(createTank(p4name.stringValue, p4color.color, 4, isCC: p4isAI, aiLvl: p4AILvl))
		}
		viewController?.initialize(terrainType: terrainType, players: players)
		viewController?.startGame()
	}

	private func createTank(_ givenName: String, _ color: NSColor, _ pNum: Int, isCC: NSButton, aiLvl: NSSegmentedControl) -> Tank {
		let name = givenName == "" ? "Player \(pNum)" : givenName
		if (isCC.state == NSOnState) {
			return CCTank(color: color, pNum: pNum, lvl: AILevel(rawValue: aiLvl.selectedSegment)!, name: name)
		} else {
			return Player(color: color, pNum: pNum, name: name)
		}
	}

	@IBAction func quitGame(_ sender: Any) {
		viewController?.quit(sender)
	}
	
}
