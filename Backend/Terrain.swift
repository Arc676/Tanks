//
//  Terrain.swift
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
Represents different types of terrain
*/
enum TerrainType : UInt32 {
	case DESERT
	case FLATLAND
	case HILLS
	case RANDOM
}

/**
Representation of the map terrain and environment
*/
class Terrain : NSView {

	let pointCount = 41 //40 + 1 (dividing a width into N pieces requires N+1 points because edges)
	var terrainBounds: NSRect?
	let skyColor = NSColor(red: 0.84, green: 0.92, blue: 1, alpha: 1)

	var terrainControlHeights: [CGFloat] = []
	var terrainWidth: Int = 0
	var chunkSize = 0
	var terrainPath: NSBezierPath?

	var terrainType: TerrainType = .DESERT
	var windAcceleration: Float = 0

	/**
	Generate a new map with the desired properties

	- parameters:
		- type: The desired terrain type
		- height: The height of the map
		- width: The width of the map
	*/
	func generateNewTerrain(_ type: TerrainType, height: UInt32, width: Int) {
		if (type == .RANDOM) {
			generateNewTerrain(TerrainType(rawValue: arc4random_uniform(TerrainType.RANDOM.rawValue))!, height: height, width: width)
			return
		}
		terrainControlHeights = [CGFloat](repeating: 0, count: pointCount)
		terrainControlHeights[0] = CGFloat(arc4random_uniform(height / 4) + height / 4)

		terrainWidth = width
		terrainType = type

		terrainBounds = NSMakeRect(0, 0, CGFloat(width), CGFloat(height))

		chunkSize = terrainWidth / (pointCount - 1)

		for i in 1..<pointCount {
			let deviation = deviationForTerrain(terrainType)
			var newHeight = terrainControlHeights[i - 1] + CGFloat(
				Int(arc4random_uniform(UInt32(deviation))) - deviation / 2
			)
			newHeight = min(max(newHeight, 0), CGFloat(height) * 0.75)
			terrainControlHeights[i] = newHeight
		}

		newWindSpeed()
	}

	/**
	Set the wind speed to a new random value
	*/
	func newWindSpeed() {
		windAcceleration = Float(arc4random_uniform(1000)) / 500
		if arc4random_uniform(100) < 50 {
			windAcceleration *= -1
		}
	}

	/**
	Deform the terrain with the specified data

	- parameters:
		- radius: The radius of the crater to form
		- xPos: The X coordinate of the impact point
	*/
	func deform(radius: CGFloat, xPos: Int) {
		let coord = xPos / chunkSize

		terrainControlHeights[coord] -= radius
		if (xPos % chunkSize > chunkSize / 2) {
			terrainControlHeights[coord + 1] -= radius
		}
	}

	/**
	Determine the maximum height deviation between chunk heights
	for the specified terrain type. Used to generate random maps.

	- parameters:
		- type: The relevant terrain type

	- returns:
	The maximum height difference between adjacent chunks for the
	terrain type
	*/
	private func deviationForTerrain(_ type: TerrainType) -> Int {
		switch type {
		case .DESERT:
			return 10
		case .FLATLAND:
			return 5
		case .HILLS:
			return 100
		default:
			return -1
		}
	}

	/**
	Determine the color of the ground for the given terrain. Used
	when drawing the terrain.

	- parameters:
		- type: The terrain type

	- returns:
	The color to be used when drawing the terrain
	*/
	private func colorForTerrain(_ type: TerrainType) -> NSColor {
		switch type {
		case .DESERT:
			return NSColor(calibratedRed: 0.86, green: 0.77, blue: 0.26, alpha: 1)
		case .FLATLAND:
			return NSColor(calibratedRed: 0, green: 200.0/255, blue: 0, alpha: 1)
		case .HILLS:
			return NSColor(calibratedRed: 0, green: 171.0/255, blue: 0, alpha: 1)
		default:
			return NSColor.white
		}
	}

	override func draw(_ rect: NSRect) {
		skyColor.set()
		rect.fill()
		
		terrainPath = NSBezierPath()
		terrainPath?.move(to: NSMakePoint(0, 0))
		for x in 0..<pointCount {
			terrainPath?.line(to: NSMakePoint(CGFloat(x * chunkSize), terrainControlHeights[x]))
		}
		terrainPath?.line(to: NSMakePoint(CGFloat(terrainWidth), 0))

		colorForTerrain(terrainType).set()
		terrainPath?.fill()
	}

}
