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

class DataEntryUrnBox extends FullBox
{

	var inFile : Bool;
	var referenceName : String;
	var location : String;

	public function new()
	{
		super("Data Entry Urn Box");
	}
	
	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		inFile = (flags&1)==1;
		if (!inFile)
		{
			referenceName = in_.readUTFString(getLeft(in_), MP4InputStream.UTF8);
			if(getLeft(in_)>0) location = in_.readUTFString(getLeft(in_), MP4InputStream.UTF8);
		}
	}

	public function isInFile()
	{
		return inFile;
	}

	public function getReferenceName()
	{
		return referenceName;
	}

	public function getLocation()
	{
		return location;
	}
}
