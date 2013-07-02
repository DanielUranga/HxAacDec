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

package ;
import flash.events.SampleDataEvent;
import flash.Memory;
import flash.net.URLStream;
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

class RawSoundSampler 
{

	private var rawInput : URLStream;
	
	public function new(b : URLStream)
	{
		this.rawInput = b;
	}
	
	public function sampleDataEvent(event : SampleDataEvent)
	{
		var b1 : UInt;
		var b2 : UInt;
		var readInt : Int;
		var pulse : Float;
		for ( i in 0...8192 )
		{
			if ( rawInput.bytesAvailable < 8 )
				break;
			b1 = rawInput.readUnsignedByte();
			b2 = rawInput.readUnsignedByte();
			readInt = (b1 << 8) | b2;
			readInt = Memory.signExtend16(readInt);
			pulse = readInt / 32768;
			event.data.writeFloat(pulse);
		}
	}
	
}