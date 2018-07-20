//
//  Shield.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 16/07/2018.
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

class Shield: Item {

	var dmgLimit: CGFloat
	var absorbed: CGFloat = 0
	var color: NSColor

	init(_ name: String, price: Int, dmgLimit: CGFloat, color: NSColor) {
		self.dmgLimit = dmgLimit
		self.color = color
		super.init(name, price: price)
	}
	
	func copy() -> Shield {
		return Shield(name, price: price, dmgLimit: dmgLimit, color: color)
	}

	required init?(coder aDecoder: NSCoder) {
		dmgLimit = aDecoder.decodeObject(forKey: "DmgLimit") as! CGFloat
		absorbed = aDecoder.decodeObject(forKey: "Absorbed") as! CGFloat
		color = aDecoder.decodeObject(forKey: "Color") as! NSColor
		super.init(coder: aDecoder)
	}

	override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(dmgLimit, forKey: "DmgLimit")
		aCoder.encode(absorbed, forKey: "Absorbed")
		aCoder.encode(color, forKey: "Color")
	}

	func draw(at point: NSPoint) {
		color.withAlphaComponent(getShieldPercentage()).set()
		let path = NSBezierPath(ovalIn: NSMakeRect(point.x - 30, point.y - 25, 60, 60))
		path.lineWidth = 5
		path.stroke()
	}

	func getShieldPercentage() -> CGFloat {
		return 1 - absorbed / dmgLimit
	}

	func absorbDamage(_ dmg: CGFloat) -> Bool {
		absorbed += dmg
		return absorbed >= dmgLimit
	}

}
