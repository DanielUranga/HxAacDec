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

package impl;
import flash.Vector;
import impl.huffman.HCB;

class SectionData 
{

	private static var MAX_SECT_COUNT : Int = 120;
	private static var BITS_LONG : Int = 5;
	private static var BITS_SHORT : Int = 3;
	private var sectCB : Vector<Vector<Int>>;
	private var sectStart : Vector<Vector<Int>>;
	private var sectEnd : Vector<Vector<Int>>;
	private var sfbCB : Vector<Vector<Int>>;
	private var numSec : Vector<Int>;
	
	public function new()
	{
		
	}
	
	public function decode(input : BitStream, info : ICSInfo, sectionDataResilienceUsed : Bool)
	{
		var bitsLen : Int = info.isEightShortFrame() ? BITS_SHORT : BITS_LONG;
		var escVal : Int = (1<<bitsLen)-1;
		var sectCBBits : Int = (sectionDataResilienceUsed) ? 5 : 4;
		var windowGroupCount : Int = info.getWindowGroupCount();
		sectCB = VectorTools.newMatrixVectorI(windowGroupCount, MAX_SECT_COUNT);
		sectStart = VectorTools.newMatrixVectorI(windowGroupCount, MAX_SECT_COUNT);
		sectEnd = VectorTools.newMatrixVectorI(windowGroupCount, MAX_SECT_COUNT);		
		sfbCB = VectorTools.newMatrixVectorI(windowGroupCount, MAX_SECT_COUNT);
		numSec = new Vector<Int>(windowGroupCount);
		var maxSFB : Int = info.getMaxSFB();
		var k, i : Int;
		var sectLen, sectLenIncr, end, sfb : Int;
		for (g in 0...windowGroupCount)
		{
			k = 0;
			i = 0;
			while (k < maxSFB)
			{
				sectCB[g][i] = input.readBits(sectCBBits);
				if (sectionDataResilienceUsed && ((sectCB[g][i] == 11) || ((sectCB[g][i] > 15) && (sectCB[g][i] < 33))))
				{
					sectLenIncr = 1;
				}
				else
				{
					sectLenIncr = input.readBits(bitsLen);
				}
				sectLen = 0;
				while (sectLenIncr == escVal)
				{
					sectLen += sectLenIncr;
					sectLenIncr = input.readBits(bitsLen);
				}
				sectLen += sectLenIncr;
				end = k+sectLen;
				sectStart[g][i] = k;
				sectEnd[g][i] = end;
				for(sfb in k...end)
				{
					sfbCB[g][sfb] = sectCB[g][i];
				}
				k += sectLen;
				i++;
			}
			numSec[g] = i;
		}
	}
	
	public function getSectEnd() : Vector<Vector<Int>>
	{
		return sectEnd;
	}

	public function getSectStart() : Vector<Vector<Int>>
	{
		return sectStart;
	}

	public function getSfbCB() : Vector<Vector<Int>>
	{
		return sfbCB;
	}

	public function getSectCB() : Vector<Vector<Int>>
	{
		return sectCB;
	}

	public function getNumSec() : Vector<Int>
	{
		return numSec;
	}

	public function isNoise(g : Int, sfb : Int) : Bool
	{
		return sfbCB[g][sfb]==HCB.NOISE_HCB;
	}

	public function isIntensity(g : Int, sfb : Int) : Int
	{
		var i : Int;
		switch(sfbCB[g][sfb])
		{
			case HCB.INTENSITY_HCB:
				i = 1;
			case HCB.INTENSITY_HCB2:
				i = -1;
			default:
				i = 0;
		}
		return i;
	}
	
}