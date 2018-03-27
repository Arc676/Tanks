//
//  Ammo.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
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

import Foundation

class Ammo: Item {

	var blastRadius: CGFloat
	var damage: CGFloat

	init(_ name: String, price: Int, radius: CGFloat, damage: CGFloat) {
		blastRadius = radius
		self.damage = damage
		super.init(name, price: price)
	}

	override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(blastRadius, forKey: "BlastRadius");
		aCoder.encode(damage, forKey: "Dmg")
	}

	required init?(coder aDecoder: NSCoder) {
		blastRadius = aDecoder.decodeObject(forKey: "BlastRadius") as! CGFloat
		damage = aDecoder.decodeObject(forKey: "Dmg") as! CGFloat
		super.init(coder: aDecoder)
	}

}
