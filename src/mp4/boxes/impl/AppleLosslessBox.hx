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

public class AppleLosslessBox extends FullBox
{
	var maxSamplePerFrame : Int;
	var maxCodedFrameSize : Int;
	var bitRate : Int;
	var sampleRate;
	var sampleSize : Int;
	var historyMult : Int;
	var initialHistory : Int;
	var kModifier : Int;
	var channels : Int;

	public function new()
	{
		super("Apple Lossless Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		maxSamplePerFrame = in_.readBytes(4);
		in_.skipBytes(1); //?
		sampleSize = in_.read();
		historyMult = in_.read();
		initialHistory = in_.read();
		kModifier = in_.read();
		channels = in_.read();
		in_.skipBytes(2); //?
		maxCodedFrameSize = in_.readBytes(4);
		bitRate = in_.readBytes(4);
		sampleRate = in_.readBytes(4);
	}

	public function getMaxSamplePerFrame() : Int
	{
		return maxSamplePerFrame;
	}

	public function getSampleSize() : Int
	{
		return sampleSize;
	}

	public function getHistoryMult() : Int
	{
		return historyMult;
	}

	public function getInitialHistory() : Int
	{
		return initialHistory;
	}

	public function getkModifier() : Int
	{
		return kModifier;
	}

	public function getChannels() : Int
	{
		return channels;
	}

	public function getMaxCodedFrameSize() : Int
	{
		return maxCodedFrameSize;
	}

	public function getBitRate() : Int
	{
		return bitRate;
	}

	public function getSampleRate() : Int
	{
		return sampleRate;
	}
}
