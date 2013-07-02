/*
 *  Copyright (C) 2011 in-somnia
 * 
 *  This file is part of JAAD.
 * 
 *  JAAD is free software; you can redistribute it and/or modify it 
 *  under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation; either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  JAAD is distributed in the hope that it will be useful, but WITHOUT 
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
package mp4.boxes.impl;

import mp4.MP4InputStream;
import mp4.boxes.FullBox;

//TODO: check decoding, add get-methods
class ColorParameterBox extends FullBox
{

	var colorParameterType : Int;
	var primariesIndex : Int;
	var transferFunctionIndex : Int;
	var matrixIndex : Int;

	public function new()
	{
		super("Color Parameter Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		colorParameterType = in_.readBytes(4);
		primariesIndex = in_.readBytes(2);
		transferFunctionIndex = in_.readBytes(2);
		matrixIndex = in_.readBytes(2);
	}
}
