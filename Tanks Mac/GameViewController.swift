//
//  ViewController.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
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
View controller for the game on Mac
*/
class GameViewController : NSViewController {

	@IBOutlet var menuView: MenuView!

	let delegate: AppDelegate = NSApp.delegate as! AppDelegate

	var windowController: WindowController?

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

	/**
	Initialize the game with the given properties

	- parameters:
		- terrainType: The desired terrain type
		- players: The entities to be in the game
	*/
	func initialize(terrainType: TerrainType) {
		if gameView == nil {
			gameView = GameViewMac(frame: view.frame)
		}
		if storeView == nil {
			storeView = StoreViewMac(frame: view.frame)
		}

		chosenTerrain = terrainType
	}

	/**
	Utility function for setting the view of the window

	- parameters:
		- newView: The new view to show in the main window
	*/
	func setView(_ newView: NSView) {
		view = newView
		NSApp.mainWindow?.makeFirstResponder(newView)
	}

	/**
	Start the game
	*/
	func startGame(_ players: [Tank]?) {
		setView(gameView!)
		gameView!.initialize(terrainType: chosenTerrain!, players: players, controller: self)
		gameView!.needsDisplay = true

		gameView?.touchBarAngleSlider = windowController?.touchBarAngleSlider
		gameView?.touchBarFirepowerSlider = windowController?.touchBarFirepowerSlider

		if players != nil {
			storeView?.savePaths = menuView.getPaths()
		}
	}

	/**
	Returns to the main menu
	*/
	func exitToMain() {
		setView(menuView)
	}

	/**
	Start the game with the current set of players
	*/
	func startGame() {
		startGame(nil)
	}

	/**
	Switch to the store view
	*/
	func goToStore() {
		setView(storeView!)
		storeView?.initialize(gameView!.players, viewController: self)
		storeView?.refresh()
	}

	/**
	Quit the game and the app

	- parameters:
		- sender: The object that sent the request
	*/
	func quit(_ sender: Any) {
		gameView?.terminate()
		delegate.terminate(sender)
	}

}
