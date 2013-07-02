/*
	Copyright 2011 Nestor Daniel Uranga
	
	This file is part of HxAacDec.

    HxAacDec is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    HxAacDec is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with HxAacDec.  If not, see <http://www.gnu.org/licenses/>.
*/

package impl.adts;
import haxe.io.BytesData;
import impl.BitStream;

class ADTSDemultiplexer 
{
	private static inline var MAXIMUM_FRAME_SIZE : Int = 6144;
	private var input : BytesData;
	private var b : BytesData;
	private var first : Bool;
	private var frame : ADTSFrame;

	public function new(input : BytesData)
	{
		b = new BytesData();
		this.input = input;
		first = true;
		if(!findNextFrame()) throw("no ADTS header found");
	}

	public function getDecoderSpecificInfo() : BytesData
	{
		return frame.createDecoderSpecificInfo();
	}

	public function readNextFrame() : BytesData
	{
		if(first) first = false;
		else findNextFrame();

		//var b : BytesData = new BytesData();
		b.length = frame.getFrameLength();
		//din.readFully(b);
		for ( i in 0...b.length )
			b[i] = input.readByte();
		return b;
	}

	private function findNextFrame() : Bool
	{
		//find next ADTS ID
		var found : Bool = false;
		var left : Int = MAXIMUM_FRAME_SIZE;
		var i : Int;
		while (!found && left > 0)
		{
			i = input.readUnsignedByte();
			left--;
			if (i == 0xFF)
			{
				var prevPos : Int = input.position;
				i = input.readByte();
				if(((i>>4)&0xF)==0xF) found = true;
				//in.unread(i);
				input.position = prevPos;
			}
		}

		if(found) frame = new ADTSFrame(input);
		return found;
	}

	public function getSampleFrequency() : Int
	{
		return frame.getSampleFrequency();
	}

	public function getChannelCount() : Int
	{
		return frame.getChannelCount();
	}
}