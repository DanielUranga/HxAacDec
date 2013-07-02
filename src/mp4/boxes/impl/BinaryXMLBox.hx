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

import haxe.io.BytesData;
import mp4.MP4InputStream;
import mp4.boxes.FullBox;

/**
 * When the primary data is in XML format and it is desired that the XML be
 * stored directly in the meta-box, either the XMLBox or the BinaryXMLBox is
 * used. The Binary XML Box may only be used when there is a single well-defined
 * binarization of the XML for that defined format as identified by the handler.
 *
 * @see XMLBox
 * @author in-somnia
 */
public class BinaryXMLBox extends FullBox
{

	//private byte[] data;
	var data : BytesData;

	public function new()
	{
		super("Binary XML Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);
		//data = new byte[(int) getLeft(in)];
		data = new BytesData();
		data.lenght = getLeft(in_);
		in_.readBytes(data);
	}

	/**
	 * The binary data.
	 */
	public function getData() : BytesData
	{
		return data;
	}
}
