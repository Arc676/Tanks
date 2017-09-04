//
//  ViewController.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
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

class GameViewController : NSViewController {

	@IBOutlet var menuView: MenuView!

	let delegate: AppDelegate = NSApp.delegate as! AppDelegate

	var gameView: GameViewMac?
	var storeView: StoreViewMac?

	var chosenTerrain: TerrainType?
	var players: [Tank]?

	override func viewDidLoad() {
		menuView.viewController = self
	}

	override func viewWillDisappear() {
		super.viewWillDisappear()
		quit(NSNull())
	}

	func initialize(terrainType: TerrainType, players: [Tank]) {
		gameView = GameViewMac(frame: (NSApp.mainWindow?.frame)!)
		storeView = StoreViewMac(frame: (NSApp.mainWindow?.frame)!)

		chosenTerrain = terrainType
		self.players = players
	}

	func updatePlayers(_ players: [Tank]) {
		self.players = players
	}

	func startGame() {
		view = gameView!
		NSApp.mainWindow?.makeFirstResponder(gameView)
		gameView!.initialize(terrainType: chosenTerrain!, players: players!, controller: self)
		gameView!.needsDisplay = true
	}

	func goToStore() {
		view = storeView!
		NSApp.mainWindow?.makeFirstResponder(storeView)
		storeView?.initialize(gameView!.players, viewController: self)
		storeView?.needsDisplay = true
	}

	func quit(_ sender: Any) {
		gameView?.terminate()
		delegate.terminate(sender)
	}

}
