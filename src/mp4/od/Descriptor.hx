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
package net.sourceforge.jaad.mp4.od;

/*
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
*/
import mp4.MP4InputStream;

/**
 * The abstract base class and factory for all descriptors (defined in ISO
 * 14496-1 as 'ObjectDescriptors').
 *
 * @author in-somnia
 */
class Descriptor
{

	public static var TYPE_OBJECT_DESCRIPTOR = 1;
	public static var TYPE_INITIAL_OBJECT_DESCRIPTOR = 2;
	public static var TYPE_ES_DESCRIPTOR = 3;
	public static var TYPE_DECODER_CONFIG_DESCRIPTOR = 4;
	public static var TYPE_DECODER_SPECIFIC_INFO = 5;
	public static var TYPE_SL_CONFIG_DESCRIPTOR = 6;
	public static var TYPE_ES_ID_INC = 14;
	public static var TYPE_MP4_INITIAL_OBJECT_DESCRIPTOR = 16;

	public static function createDescriptor(in_ : MP4InputStream) : Descriptor
	{
		//read tag and size
		var type = in_.read();
		var read = 1;
		var size = 0;
		var b = 0;
		do {
			b = in_.read();
			size <<= 7;
			size |= b&0x7f;
			read++;
		}
		while((b&0x80)==0x80);

		//create descriptor
		var desc = forTag(type);
		desc.type = type;
		desc.size = size;
		desc.start = in_.getOffset();

		//decode
		desc.decode(in_);
		//skip remaining bytes
		var remaining = size-(in_.getOffset()-desc.start);
		if (remaining > 0)
		{
			//Logger.getLogger("MP4 Boxes").log(Level.INFO, "Descriptor: bytes left: {0}, offset: {1}", new Long[]{remaining, in.getOffset()});
			in_.skipBytes(remaining);
		}
		desc.size += read; //include type and size fields

		return desc;
	}

	private static function forTag(tag : Int) : Descriptor
	{
		Descriptor desc;
		switch(tag)
		{
			case TYPE_OBJECT_DESCRIPTOR:
				{
					desc = new ObjectDescriptor();
				}
			case TYPE_INITIAL_OBJECT_DESCRIPTOR:
				{ };
			case TYPE_MP4_INITIAL_OBJECT_DESCRIPTOR:
				{
					desc = new InitialObjectDescriptor();
				}
			case TYPE_ES_DESCRIPTOR:
				{
					desc = new ESDescriptor();
				}
			case TYPE_DECODER_CONFIG_DESCRIPTOR:
				{
					desc = new DecoderConfigDescriptor();
				}
			case TYPE_DECODER_SPECIFIC_INFO:
				{
					desc = new DecoderSpecificInfo();
				}
			case TYPE_SL_CONFIG_DESCRIPTOR:
			//desc = new SLConfigDescriptor();
			//break;
			default:
				{
					//Logger.getLogger("MP4 Boxes").log(Level.INFO, "Unknown descriptor type: {0}", tag);
					desc = new UnknownDescriptor();
				}
		}
		return desc;
	}
	var type : Int;
	var size : Int;
	var start : Int;
	var children : List<Descriptor>;

	public function new()
	{
		children = new List<Descriptor>();
	}

	function decode(in_ : MP4InputStream) : Void {};

	//children
	function readChildren(MP4InputStream in) : Void
	{
		Descriptor desc;
		while((size-(in.getOffset()-start))>0) {
			desc = createDescriptor(in);
			children.add(desc);
		}
	}

	public List<Descriptor> getChildren() {
		return Collections.unmodifiableList(children);
	}

	//getter
	public int getType() {
		return type;
	}

	public int getSize() {
		return size;
	}
}
