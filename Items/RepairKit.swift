//
//  RepairKit.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 20/07/2018.
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

class RepairKit: Item {

	let HPGain: CGFloat = 20

	init(price: Int) {
		super.init("Repair Kit", price: price)
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

}
