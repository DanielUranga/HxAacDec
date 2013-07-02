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
import mp4.boxes.BoxImpl;

class CleanApertureBox extends BoxImpl
{

	var cleanApertureWidthN : Int;
	var cleanApertureWidthD : Int;
	var cleanApertureHeightN : Int;
	var cleanApertureHeightD : Int;
	var horizOffN : Int;
	var horizOffD : Int;
	var vertOffN : Int;
	var vertOffD : Int;

	public function()
	{
		super("Clean Aperture Box");
	}
	
	override function decode(in_ : mp4.MP4InputStream)
	{
		cleanApertureWidthN = in_.readBytes(4);
		cleanApertureWidthD = in_.readBytes(4);
		cleanApertureHeightN = in_.readBytes(4);
		cleanApertureHeightD = in_.readBytes(4);
		horizOffN = in_.readBytes(4);
		horizOffD = in_.readBytes(4);
		vertOffN = in_.readBytes(4);
		vertOffD = in_.readBytes(4);
	}

	public function getCleanApertureWidthN()
	{
		return cleanApertureWidthN;
	}

	public function getCleanApertureWidthD()
	{
		return cleanApertureWidthD;
	}

	public function getCleanApertureHeightN()
	{
		return cleanApertureHeightN;
	}

	public function getCleanApertureHeightD()
	{
		return cleanApertureHeightD;
	}

	public function getHorizOffN()
	{
		return horizOffN;
	}

	public functiongetHorizOffD()
	{
		return horizOffD;
	}

	public function getVertOffN()
	{
		return vertOffN;
	}

	public function getVertOffD()
	{
		return vertOffD;
	}
}
