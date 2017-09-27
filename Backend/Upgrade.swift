//
//  Upgrade.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 27/09/2017.
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

class Upgrade: Item {

	var type: UpgradeType
	var upgradeQty: CGFloat

	init(_ name: String, _ qty: CGFloat, price: Int, type: UpgradeType) {
		self.type = type
		self.upgradeQty = qty
		super.init(name, price: price)
	}

}
