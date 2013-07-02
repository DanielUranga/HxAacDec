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
import impl.BitStream;
import impl.PCE;
import flash.Vector;

class ADIFHeader 
{

	private static var ADIF_ID : Int = 0x41444946; //'ADIF'
	private var id : Int;
	private var copyrightIDPresent : Bool;
	private var copyrightID : Vector<Int>;
	private var originalCopy : Bool;
	private var home : Bool;
	private var bitstreamType : Bool;
	private var bitrate : Int;
	private var pceCount : Int;
	private var adifBufferFullness : Vector<Int>;
	private var pces : Vector<PCE>;

	public static function isPresent(input : BitStream) : Bool
	{
		return input.peekBits(32)==ADIF_ID;
	}

	private function new()
	{
		copyrightID = new Vector<Int>(9);
		pces = null;
	}

	public static function readHeader(input : BitStream) : ADIFHeader
	{
		var h : ADIFHeader = new ADIFHeader();
		h.decode(input);
		return h;
	}

	private function decode(input : BitStream)
	{
		id = input.readBits(32); //'ADIF'
		copyrightIDPresent = input.readBool();
		if (copyrightIDPresent)
		{
			for (i in 0...9)
			{
				copyrightID[i] = input.readBits(8);
			}
		}
		originalCopy = input.readBool();
		home = input.readBool();
		bitstreamType = input.readBool();
		bitrate = input.readBits(23);
		pceCount = input.readBits(4)+1;
		pces = new Vector<PCE>(pceCount);
		adifBufferFullness = new Vector<Int>(pceCount);
		for (i in 0...pceCount)
		{
			if(bitstreamType) adifBufferFullness[i] = -1;
			else adifBufferFullness[i] = input.readBits(20);
			pces[i] = new PCE();
			pces[i].decode(input);
		}
	}

	public function getFirstPCE() : PCE
	{
		return pces[0];
	}
	
}