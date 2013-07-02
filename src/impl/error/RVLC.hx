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
	
package impl.error;
import flash.Vector;
import impl.BitStream;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntMath;
import impl.huffman.HCB;

class RVLC 
{
	private static var ESCAPE_FLAG : Int = 7;

	public function new()
	{
		
	}
	
	public function decode(input : BitStream, ics : ICStream, scaleFactors : Vector<Vector<Int>>)
	{
		var bits : Int = (ics.getInfo().isEightShortFrame()) ? 11 : 9;
		var sfConcealment : Bool = input.readBool();
		var revGlobalGain : Int = input.readBits(8);
		var rvlcSFLen : Int = input.readBits(bits);

		var info : ICSInfo = ics.getInfo();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var maxSFB : Int = info.getMaxSFB();
		var sfbCB : Vector<Vector<Int>> = ics.getSectionData().getSfbCB();

		var sf : Int = ics.getGlobalGain();
		var intensityPosition : Int = 0;
		var noiseEnergy : Int = sf-90-256;
		var intensityUsed : Bool = false;
		var noiseUsed : Bool = false;

		var sfb : Int;
		for (g in 0...windowGroupCount)
		{
			for (sfb in 0...maxSFB)
			{
				switch(sfbCB[g][sfb])
				{
					case HCB.ZERO_HCB:
					{
						scaleFactors[g][sfb] = 0;
					}
					case HCB.INTENSITY_HCB, HCB.INTENSITY_HCB2:
					{
						if(!intensityUsed) intensityUsed = true;
						intensityPosition += decodeHuffman(input);
						scaleFactors[g][sfb] = intensityPosition;
					}
					case HCB.NOISE_HCB:
					{
						if (!noiseUsed)
						{
							noiseUsed = true;
							noiseEnergy = decodeHuffman(input);
						}
						else
						{
							noiseEnergy += decodeHuffman(input);
							scaleFactors[g][sfb] = noiseEnergy;
						}
					}
					default:
					{
						sf += decodeHuffman(input);
						scaleFactors[g][sfb] = sf;
					}
				}
			}
		}

		var lastIntensityPosition : Int = 0;
		if(intensityUsed) lastIntensityPosition = decodeHuffman(input);
		noiseUsed = false;
		if(input.readBool()) decodeEscapes(input, ics, scaleFactors);
	}

	private function decodeEscapes(input : BitStream, ics : ICStream, scaleFactors : Vector<Vector<Int>>)
	{
		var info : ICSInfo = ics.getInfo();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var maxSFB : Int = info.getMaxSFB();
		var sfbCB : Vector<Vector<Int>> = ics.getSectionData().getSfbCB();

		var escapesLen : Int = input.readBits(8);

		var noiseUsed : Bool = false;

		var val : Int;
		for (g in 0...windowGroupCount)
		{
			for (sfb in 0...maxSFB)
			{
				if(sfbCB[g][sfb]==HCB.NOISE_HCB&&!noiseUsed) noiseUsed = true;
				else if (IntMath.abs(sfbCB[g][sfb]) == ESCAPE_FLAG)
				{
					val = decodeHuffmanEscape(input);
					if(sfbCB[g][sfb]==-ESCAPE_FLAG) sfbCB[g][sfb] -= val;
					else sfbCB[g][sfb] += val;
				}
			}
		}
	}

	private function decodeHuffman(input : BitStream) : Int
	{
		var off : Int = 0;
		var i : Int = RVLCTables.RVLC_BOOK[off][1];
		var cw : Int = input.readBits(i);

		var j : Int;
		while ((cw != RVLCTables.RVLC_BOOK[off][2]) && (i < 10))
		{
			off++;
			j = RVLCTables.RVLC_BOOK[off][1]-i;
			i += j;
			cw <<= j;
			cw |= input.readBits(j);
		}

		return RVLCTables.RVLC_BOOK[off][0];
	}

	private function decodeHuffmanEscape(input : BitStream) : Int
	{
		var off : Int = 0;
		var i : Int = RVLCTables.ESCAPE_BOOK[off][1];
		var cw : Int = input.readBits(i);

		var j : Int;
		while ((cw != RVLCTables.ESCAPE_BOOK[off][2]) && (i < 21))
		{
			off++;
			j = RVLCTables.ESCAPE_BOOK[off][1]-i;
			i += j;
			cw <<= j;
			cw |= input.readBits(j);
		}

		return RVLCTables.ESCAPE_BOOK[off][0];
	}
	
}