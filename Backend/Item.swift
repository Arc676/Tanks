//
//  Item.swift
//  Tanks
//
//  Created by Alessandro Vinciguerra on 03/09/2017.
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

import Foundation

/**
Representation of purchasable items
that can be archived and written to disk
*/
class Item: NSObject, NSCoding {

	var price: Int
	var name: String

	/**
	Create a new item

	- parameters:
		- name: Name of item
		- price: Price of item
	*/
	init(_ name: String, price: Int) {
		self.name = name
		self.price = price
	}

	func encode(with aCoder: NSCoder) {
		aCoder.encode(price, forKey: "Price")
		aCoder.encode(name, forKey: "Name")
	}

	required init?(coder aDecoder: NSCoder) {
		price = aDecoder.decodeInteger(forKey: "Price")
		name = aDecoder.decodeObject(forKey: "Name") as! String
	}

}
