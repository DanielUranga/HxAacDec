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

/**
 * This class is used for all boxes, that are known but don't contain necessary 
 * data and can be skipped. This is mainly used for 'skip', 'free' and 'wide'.
 * 
 * @author in-somnia
 */
class FreeSpaceBox extends BoxImpl
{

	public function new()
	{
		super("Free Space Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		//no need to read, box will be skipped
	}
}
