//
//  SeparationWeapon.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 2018/05/22.
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

import Foundation
import AppKit

/**
Base representation for any weapon that
consists of a predetermined but variable
number of projectiles
*/
class SeparationWeapon: Ammo {

	var projCount = 0

	/**
	Create a new object representing a separating weapon

	- parameters:
	- name: Name of ammunition type
	- price: Price of the ammunition
	- radius: Blast radius for this type of ammunition
	- damage: Damage dealt by the ammunition at zero range
	- sound: The sound file to be played on impact
	- projCount: The number of sub-projectiles to spawn when firing
	*/
	init(_ name: String, price: Int, radius: Int, damage: CGFloat, sound: NSSound, projCount: Int) {
		self.projCount = projCount
		super.init(name, price: price, radius: radius, damage: damage, sound: sound)
	}

	override func encode(with aCoder: NSCoder) {
		aCoder.encode(projCount, forKey: "ProjCount")
		super.encode(with: aCoder)
	}

	required init?(coder aDecoder: NSCoder) {
		projCount = aDecoder.decodeInteger(forKey: "ProjCount")
		super.init(coder: aDecoder)
	}

}
