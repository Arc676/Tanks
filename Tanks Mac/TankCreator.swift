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

class TankCreator: NSView {
	@IBOutlet weak var tankDesignBox: NSBox!

	@IBOutlet weak var enablePlayer: NSButton!
	
	@IBOutlet weak var tankName: NSTextField!
	@IBOutlet weak var tankColor: NSColorWell!

	@IBOutlet weak var isCCTank: NSButton!
	@IBOutlet weak var tankAILevel: NSSegmentedControl!
	
	@IBOutlet weak var loadButton: NSButton!
	@IBOutlet weak var unloadButton: NSButton!

	@IBAction func togglePlayerEnabled(_ sender: NSButton) {
	}

	@IBAction func toggleCC(_ sender: NSButton) {
	}

	@IBAction func loadTank(_ sender: Any) {
	}

	@IBAction func unloadTank(_ sender: Any) {
	}
	
}
