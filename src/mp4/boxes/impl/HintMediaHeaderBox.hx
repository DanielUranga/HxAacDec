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
 * The hint media header contains general information, independent of the
 * protocol, for hint tracks.
 *
 * @author in-somnia
 */
class HintMediaHeaderBox extends FullBox
{

	var maxPDUsize : Int;
	var avgPDUsize : Int;
	var maxBitrate : Int;
	var avgBitrate : Int;

	public function new()
	{
		super("Hint Media Header Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		maxPDUsize = in_.readBytes(2);
		avgPDUsize = in_.readBytes(2);

		maxBitrate = in_.readBytes(4);
		avgBitrate = in_.readBytes(4);

		in_.skipBytes(4); //reserved
	}

	/**
	 * The maximum PDU size gives the size in bytes of the largest PDU (protocol
	 * data unit) in this hint stream.
	 */
	public function getMaxPDUsize()
	{
		return maxPDUsize;
	}

	/**
	 * The average PDU size gives the average size of a PDU over the entire
	 * presentation.
	 */
	public function getAveragePDUsize()
	{
		return avgPDUsize;
	}

	/**
	 * The maximum bitrate gives the maximum rate in bits/second over any window
	 * of one second.
	 */
	public function getMaxBitrate()
	{
		return maxBitrate;
	}

	/**
	 * The average bitrate gives the average rate in bits/second over the entire
	 * presentation.
	 */
	public function getAverageBitrate()
	{
		return avgBitrate;
	}
}
