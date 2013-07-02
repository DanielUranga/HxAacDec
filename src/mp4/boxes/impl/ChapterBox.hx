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

/**
 * The chapter box allows to specify individual chapters along the main timeline
 * of a movie. The chapter box occurs within a movie box.
 * Defined in "Adobe Video File Format Specification v10".
 *
 * @author in-somnia
 */
public class ChapterBox extends FullBox
{

	//private final Map<Long, String> chapters;
	var chapters : Map<Int, String>;

	public ChapterBox()
	{
		super("Chapter Box");
		chapters = new Map<Int, String>();
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);
		
		in_.skipBytes(4); //??
		
		var count = in_.read();
		
		var timestamp : Int;
		var len : Int;
		String name;
		for (i in 0...count)
		{
			timestamp = in_.readBytes(8);
			len = in_.read();
			name = in_.readString(len);
			chapters.put(timestamp, name);
		}
	}

	/**
	 * Returns a map that maps the timestamp of each chapter to its name.
	 *
	 * @return the chapters
	 */
	public function getChapters()
	{
		return chapters;
	}
}
