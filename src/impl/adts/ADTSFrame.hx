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
import flash.Vector;
import haxe.io.BytesData;

class ADTSFrame 
{

	//fixed
	private var id : Bool;
	private var protectionAbsent : Bool;
	private var privateBit : Bool;
	private var copy : Bool;
	private var home : Bool;
	private var layer : Int;
	private var profile : Int;
	private var sampleFrequency : Int;
	private var channelConfiguration : Int;
	//variable
	private var copyrightIDBit : Bool;
	private var copyrightIDStart : Bool;
	private var frameLength : Int;
	private var adtsBufferFullness : Int;
	private var rawDataBlockCount : Int;
	//error check
	private var rawDataBlockPosition : Vector<Int>;
	private var crcCheck : Int;
	//decoder specific info
	private var info : BytesData;

	public function new(input : BytesData)
	{
		readHeader(input);

		if(!protectionAbsent) crcCheck = input.readUnsignedShort();
		if (rawDataBlockCount == 0)
		{
			//raw_data_block();
		}
		else
		{
			//header error check
			if (!protectionAbsent)
			{
				rawDataBlockPosition = new Vector<Int>(rawDataBlockCount);
				for (i in 0...rawDataBlockCount)
				{
					rawDataBlockPosition[i] = input.readUnsignedShort();
				}
				crcCheck = input.readUnsignedShort();
			}
			//raw data blocks
			for (i in 0...rawDataBlockCount)
			{
				//raw_data_block();
				if(!protectionAbsent) crcCheck = input.readUnsignedShort();
			}
		}
	}

	private function readHeader(input : BytesData)
	{
		//fixed header:
		//1 bit ID, 2 bits layer, 1 bit protection absent		
		var i : Int = input.readByte();
		id = ((i>>3)&0x1)==1;
		layer = (i>>1)&0x3;
		protectionAbsent = (i&0x1)==1;
		if(!protectionAbsent) trace("\t\tCRC!!!");

		//2 bits profile, 4 bits sample frequency, 1 bit private bit
		i = input.readByte();
		profile = ((i>>6)&0x3)+1;
		sampleFrequency = (i>>2)&0xF;
		privateBit = ((i>>1)&0x1)==1;

		//3 bits channel configuration, 1 bit copy, 1 bit home
		i = (i<<8)|input.readByte();
		channelConfiguration = ((i>>6)&0x7);
		copy = ((i>>5)&0x1)==1;
		home = ((i>>4)&0x1)==1;
		//int emphasis = in.readBits(2);

		//variable header:
		//1 bit copyrightIDBit, 1 bit copyrightIDStart, 13 bits frame length,
		//11 bits adtsBufferFullness, 2 bits rawDataBlockCount
		copyrightIDBit = ((i>>3)&0x1)==1;
		copyrightIDStart = ((i>>2)&0x1)==1;
		i = (i<<16)|input.readUnsignedShort();
		frameLength = (i>>5)&0x1FFF;
		i = (i<<8)|input.readByte();
		adtsBufferFullness = (i>>2)&0x7FF;
		rawDataBlockCount = i&0x3;
	}

	public function getFrameLength() : Int
	{
		return frameLength-(protectionAbsent ? 7 : 9);
	}

	public function createDecoderSpecificInfo() : BytesData
	{
		if (info == null)
		{
			//5 bits profile, 4 bits sample frequency, 4 bits channel configuration
			info = new BytesData();
			info.length = 2;
			info[0] = (profile<<3);
			info[0] |= (sampleFrequency>>1)&0x7;
			info[1] = ((sampleFrequency&0x1)<<7);
			info[1] |= (channelConfiguration<<3);
			/*1 bit frame length flag, 1 bit depends on core coder,
			1 bit extension flag (all three currently 0)*/
		}

		return info;
	}

	public function getSampleFrequency() : Int
	{
		return SampleFrequency.forInt(sampleFrequency).getFrequency();
	}

	public function getChannelCount() : Int
	{
		return ChannelConfiguration.forInt(channelConfiguration).getChannelCount();
	}
	
}