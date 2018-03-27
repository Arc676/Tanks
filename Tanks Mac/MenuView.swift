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
	@IBOutlet weak var p1Path: NSPathControl!
	@IBOutlet weak var p1Load: NSButton!
	@IBOutlet weak var p1Unload: NSButton!

	//player 2
	@IBOutlet weak var p2name: NSTextField!
	@IBOutlet weak var p2color: NSColorWell!
	@IBOutlet weak var p2isAI: NSButton!
	@IBOutlet weak var p2AILvl: NSSegmentedControl!
	@IBOutlet weak var p2Path: NSPathControl!
	@IBOutlet weak var p2Load: NSButton!
	@IBOutlet weak var p2Unload: NSButton!

	//player 3
	@IBOutlet weak var enableP3: NSButton!
	@IBOutlet weak var p3name: NSTextField!
	@IBOutlet weak var p3color: NSColorWell!
	@IBOutlet weak var p3isAI: NSButton!
	@IBOutlet weak var p3AILvl: NSSegmentedControl!
	@IBOutlet weak var p3Path: NSPathControl!
	@IBOutlet weak var p3Load: NSButton!
	@IBOutlet weak var p3Unload: NSButton!

	//player 4
	@IBOutlet weak var enableP4: NSButton!
	@IBOutlet weak var p4name: NSTextField!
	@IBOutlet weak var p4color: NSColorWell!
	@IBOutlet weak var p4isAI: NSButton!
	@IBOutlet weak var p4AILvl: NSSegmentedControl!
	@IBOutlet weak var p4Path: NSPathControl!
	@IBOutlet weak var p4Load: NSButton!
	@IBOutlet weak var p4Unload: NSButton!

	@IBAction func togglePlayer(_ sender: NSButton) {
		let state = sender.state == NSControl.StateValue.on
		if sender == enableP3 {
			p3name.isEnabled = state
			p3color.isEnabled = state
			p3isAI.isEnabled = state
			p3AILvl.isEnabled = state
			p3Load.isEnabled = state
			p3Unload.isEnabled = state
		} else {
			p4name.isEnabled = state
			p4color.isEnabled = state
			p4isAI.isEnabled = state
			p4AILvl.isEnabled = state
			p4Load.isEnabled = state
			p4Unload.isEnabled = state
		}
	}

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
	
	@IBAction func loadFromFile(_ sender: NSButton) {
		//
	}

	@IBAction func unloadFile(_ sender: NSButton) {
		//
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
		if (isCC.state == NSControl.StateValue.on) {
			return CCTank(color: color, pNum: pNum, lvl: AILevel(rawValue: aiLvl.selectedSegment)!, name: name)
		} else {
			return Player(color: color, pNum: pNum, name: name)
		}
	}

	@IBAction func quitGame(_ sender: Any) {
		viewController?.quit(sender)
	}
	
}
