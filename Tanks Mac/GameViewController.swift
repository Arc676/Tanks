//
//  ViewController.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 24/07/2017.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2017 Arc676/Alessandro Vinciguerra

//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.

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
	var gameInProgress: Bool = false

	override func viewDidLoad() {
		menuView.viewController = self
	}

	override func viewWillDisappear() {
		super.viewWillDisappear()
		quit(NSNull())
	}

	func startGame(terrainType: TerrainType, players: [Tank]) {
		gameView = GameViewMac(frame: (NSApp.mainWindow?.frame)!)

		view = gameView!
		NSApp.mainWindow?.makeFirstResponder(gameView)
		gameView!.initialize(terrainType: terrainType, players: players)
		gameView!.needsDisplay = true
		gameInProgress = true
	}

	func quit(_ sender: Any) {
		gameView?.terminate()
		delegate.terminate(sender)
	}

}
