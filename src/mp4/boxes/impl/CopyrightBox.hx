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
import mp4.boxes.BoxTypes;
import mp4.boxes.FullBox;
import mp4.boxes.Utils;

/**
 * The Copyright box contains a copyright declaration which applies to the
 * entire presentation, when contained within the Movie Box, or, when contained
 * in a track, to that entire track. There may be multiple copyright boxes using
 * different language codes.
 */
class CopyrightBox extends FullBox
{

	var languageCode : String;
	var notice : String;

	public function new()
	{
		super("Copyright Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		if(parent.getType()==BoxTypes.USER_DATA_BOX)
		{
			super.decode(in_);
			//1 bit padding, 5*3 bits language code (ISO-639-2/T)
			languageCode = Utils.getLanguageCode(in_.readBytes(2));

			notice = in_.readUTFString(getLeft(in_));
		}
		else if(parent.getType()==BoxTypes.ITUNES_META_LIST_BOX) readChildren(in_);
	}

	/**
	 * The language code for the following text. See ISO 639-2/T for the set of
	 * three character codes.
	 */
	public function getLanguageCode()
	{
		return languageCode;
	}

	/**
	 * The copyright notice.
	 */
	public function getNotice()
	{
		return notice;
	}
}
