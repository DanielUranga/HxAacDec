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

package impl.transport;
import flash.Vector;
import impl.BitStream;

class ADTSFrame 
{

	private static var ADTS_ID = 0xFFF;
	//fixed
	private var id : Bool;
	private var layer : Int;
	private var protectionAbsent : Bool;
	private var profile : Profile;
	private var sampleFrequency : SampleFrequency;
	private var privateBit : Bool;
	private var channelConfiguration : ChannelConfiguration;
	private var copy : Bool;
	private var home : Bool;
	//variable
	private var copyrightIDBit : Bool;
	private var copyrightIDStart : Bool;
	private var frameLength : Int;
	private var adtsBufferFullness : Int;
	private var rawDataBlockCount : Int;
	//error check
	private var rawDataBlockPosition : Vector<Int>;
	private var crcCheck : Int;

	private function new()
	{
	}

	public static function isPresent(input : BitStream) : Bool
	{
		return input.peekBits(12)==ADTS_ID;
	}

	public static function readFrame(input : BitStream) : ADTSFrame
	{
		var frame : ADTSFrame = new ADTSFrame();
		frame.decode(input);
		return frame;
	}

	private function decode(input : BitStream)
	{
		readFixedHeader(input);
		readVariableHeader(input);
		if (!protectionAbsent) crcCheck = input.readBits(16);
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
					rawDataBlockPosition[i] = input.readBits(16);
				}
				crcCheck = input.readBits(16);
			}
			//raw data blocks
			for (i in 0...rawDataBlockCount)
			{
				//raw_data_block();
				if(!protectionAbsent) crcCheck = input.readBits(16);
			}
		}
	}

	private function readFixedHeader(input : BitStream)
	{
		input.readBits(12);
		id = input.readBool();
		layer = input.readBits(2);
		protectionAbsent = input.readBool();
		profile = Profile.forInt(input.readBits(2));
		sampleFrequency = SampleFrequency.forInt(input.readBits(4));
		privateBit = input.readBool();
		channelConfiguration = ChannelConfiguration.forInt(input.readBits(3));
		copy = input.readBool();
		home = input.readBool();
		//int emphasis = in.readBits(2);
	}

	private function readVariableHeader(input : BitStream)
	{
		copyrightIDBit = input.readBool();
		copyrightIDStart = input.readBool();
		frameLength = input.readBits(13);
		adtsBufferFullness = input.readBits(11);
		rawDataBlockCount = input.readBits(2);
	}

	/* getter */
	public function getProfile() : Profile
	{
		return profile;
	}

	public function getSampleFrequency() : SampleFrequency
	{
		return sampleFrequency;
	}

	public function getChannelConfiguration() : ChannelConfiguration
	{
		return channelConfiguration;
	}
	
}