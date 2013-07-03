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
 * This box within a Media Box declares the process by which the media-data in
 * the track is presented, and thus, the nature of the media in a track. For
 * example, a video track would be handled by a video handler.
 *
 * This box when present within a Meta Box, declares the structure or format of
 * the 'meta' box contents.
 *
 * There is a general handler for metadata streams of any type; the specific
 * format is identified by the sample entry, as for video or audio, for example.
 * If they are in text, then a MIME format is supplied to document their format;
 * if in XML, each sample is a complete XML document, and the namespace of the
 * XML is also supplied.
 * @author in-somnia
 */
class HandlerBox extends FullBox
{

	//ISO BMFF types
	public static var TYPE_VIDEO = 1986618469; //vide
	public static var TYPE_SOUND = 1936684398; //soun
	public static var TYPE_HINT = 1751740020; //hint
	public static var TYPE_META = 1835365473; //meta
	public static var TYPE_NULL = 1853189228; //null
	//MP4 types
	public static var TYPE_ODSM = 1868854125; //odsm
	public static var TYPE_CRSM = 1668445037; //crsm
	public static var TYPE_SDSM = 1935962989; //sdsm
	public static var TYPE_M7SM = 1832350573; //m7sm
	public static var TYPE_OCSM = 1868788589; //ocsm
	public static var TYPE_IPSM = 1768977261; //ipsm
	public static var TYPE_MJSM = 1835692909; //mjsm
	var handlerType : Int;
	var handlerName : String;

	public function new()
	{
		super("Handler Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		in_.skipBytes(4); //pre-defined: 0

		handlerType = in_.readBytes(4);

		in_.readBytes(4); //reserved
		in_.readBytes(4); //reserved
		in_.readBytes(4); //reserved

		handlerName = in_.readUTFString(getLeft(in_), MP4InputStream.UTF8);
	}

	/**
	 * When present in a media box, the handler type is an integer containing
	 * one of the following values:
	 * <ul>
	 * <li>'vide': Video track</li>
	 * <li>'soun': Audio track</li>
	 * <li>'hint': Hint track</li>
	 * <li>'meta': Timed Metadata track</li>
	 * </ul>
	 *
	 * When present in a meta box, it contains an appropriate value to indicate
	 * the format of the meta box contents. The value 'null' can be used in the
	 * primary meta box to indicate that it is merely being used to hold
	 * resources.
	 *
	 * @return the handler type
	 */
	public function getHandlerType()
	{
		return handlerType;
	}

	/**
	 * The name gives a human-readable name for the track type (for debugging
	 * and inspection purposes).
	 * 
	 * @return the handler type's name
	 */
	public function getHandlerName()
	{
		return handlerName;
	}
}
