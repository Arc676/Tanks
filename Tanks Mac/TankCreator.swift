//
//  TankCreator.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/05/06.
//	<alesvinciguerra@gmail.com>
//Copyright (C) 2018 Arc676/Alessandro Vinciguerra

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

@IBDesignable

class TankCreator: NSView {
	
	@IBOutlet weak var tankDesignBox: NSBox!

	@IBOutlet weak var enablePlayer: NSButton!
	
	@IBOutlet weak var tankName: NSTextField!
	@IBOutlet weak var tankColor: NSColorWell!

	@IBOutlet weak var isCCTank: NSButton!
	@IBOutlet weak var tankAILevel: NSSegmentedControl!
	@IBOutlet weak var tankAIStyle: NSSegmentedControl!
	
	@IBOutlet weak var loadButton: NSButton!
	@IBOutlet weak var unloadButton: NSButton!

	private var tank: Tank?

	@IBOutlet weak var contentView: NSView?

	required init?(coder decoder: NSCoder) {
		super.init(coder: decoder)
		xibSetup()
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		xibSetup()
	}

	/**
	Load the view from the XIB file
	*/
	func xibSetup() {
		Bundle.main.loadNibNamed(NSNib.Name("TankCreator"), owner: self, topLevelObjects: nil)
		addSubview(contentView!)
		contentView?.frame = self.bounds
	}

	/**
	Set values for tank properties
	*/
	func setState(_ name: String, color: NSColor, canDisable: Bool) {
		tankDesignBox.title = name
		tankColor.color = color
		enablePlayer.isHidden = !canDisable
	}

	/**
	Toggle whether a player is enabled and enable or
	disable the corresponding UI elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func togglePlayerEnabled(_ sender: NSButton) {
		let state = sender.state == NSControl.StateValue.on
		setPlayerEnabled(state)
	}

	/**
	Toggles the state of all UI elements to match whether the player's properties are editable

	- parameters:
		- state: Whether the player's properties can be modified
	*/
	func setPlayerEnabled(_ state: Bool) {
		let isLoaded = tank != nil
		tankName.isEnabled = state && !isLoaded
		tankColor.isEnabled = state && !isLoaded
		isCCTank.isEnabled = state && !isLoaded
		// AI specific controls
		tankAILevel.isEnabled = state && isCCTank.state == NSControl.StateValue.on
		tankAIStyle.isEnabled = tankAILevel.isEnabled
		// disk loading control
		loadButton.isEnabled = state && !isLoaded
		unloadButton.isEnabled = state && isLoaded
	}

	/**
	Toggle whether a player should be computer controlled
	and enable or disable UI elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func toggleCC(_ sender: NSButton) {
		let state = sender.state == NSControl.StateValue.on
		tankAILevel.isEnabled = state
		tankAIStyle.isEnabled = state
	}

	/**
	Indicate that a tank should be loaded from a
	file when the game starts, ask for the file from
	which the player should be loaded, and disable UI
	elements accordingly

	- parameters:
		- sender: Button clicked
	*/
	@IBAction func loadTank(_ sender: Any) {
		var failed = true
		let panel = NSOpenPanel()
		if panel.runModal() == NSApplication.ModalResponse.OK {
			do {
				let data = try Data(contentsOf: panel.url!)
				if let tank = NSKeyedUnarchiver.unarchiveObject(with: data) as? Tank {
					self.tank = tank
					tankName.stringValue = tank.name!
					tankColor.color = tank.tankColor!
					setPlayerEnabled(false)
					unloadButton.isEnabled = true
					failed = false
				}
			} catch {}
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
	@IBAction func unloadTank(_ sender: Any) {
		tank = nil
		setPlayerEnabled(true)
	}

	/**
	Gets the tank loaded from disk or creates a new tank with
	the given properties

	- returns:
	The loaded or newly created tank
	*/
	func getTank() -> Tank? {
		// if player is disabled, return nothing
		if enablePlayer.state == NSControl.StateValue.off {
			return nil
		}
		// if tank has been loaded from file, return loaded tank
		if tank != nil {
			return tank
		}
		// otherwise create a new tank with the given properties
		let name = tankName.stringValue == "" ? MenuView.getRandomName() : tankName.stringValue
		if (isCCTank.state == NSControl.StateValue.on) {
			return CCTank(
				color: tankColor.color,
				pNum: 0,
				lvl: AILevel(rawValue: tankAILevel.selectedSegment)!,
				style: AIStyle(rawValue: UInt32(tankAIStyle.selectedSegment))!,
				name: name)
		} else {
			return Player(
				color: tankColor.color,
				pNum: 0,
				name: name)
		}
	}
	
}
