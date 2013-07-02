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
	
package impl.invquant;
import flash.Vector;
import impl.ICSInfo;
import impl.IntMath;

class InvQuant 
{

	private function new()
	{
	}

	public static function process(info : ICSInfo, input : Vector<Int>, out : Vector<Float>, scaleFactors : Vector<Vector<Int>>)
	{
		var windowGroupCount : Int = info.getWindowGroupCount();
		var sectSFBOffsets : Vector<Int> = info.getSWBOffsets();
		var maxSFB : Int = info.getMaxSFB();
		var swbCount : Int = info.getSWBCount();
		var sfb : Int;
		var win : Int;
		var width : Int;
		var bin : Int;
		var wa : Int;
		var wb : Int;
		var j : Int;
		var gInc : Int;
		var winInc : Int;
		var sf : Int;
		var gain : Float;

		var k : Int = 0;
		var gindex : Int = 0;

		for ( g in 0...windowGroupCount )
		{
			j = 0;
			gInc = 0;
			winInc = sectSFBOffsets[swbCount];

			sfb = 0;
			while ( sfb<swbCount && maxSFB>0 )
			{
				width = sectSFBOffsets[sfb+1]-sectSFBOffsets[sfb];
				wa = gindex+j;

				sf = scaleFactors[g][IntMath.min(sfb, maxSFB-1)];
				if(sf<0||sf>255) gain = 0;
				else gain = computeGain(sf);

				for (win in 0...info.getWindowGroupLength(g))
				{
					for (bin in 0...width)
					{
						wb = wa+bin;
						out[wb] = computeInvQuant(input[k])*gain;
						gInc++;
						k++;
					}
					wa += winInc;
				}
				j += width;
				sfb++;
			}
			gindex += gInc;			
		}
	}

	/**
	 * iq = sgn(q)*abs(q)<sup>4/3</sup>
	 */
	private static function computeInvQuant(q : Int) : Float
	{
		var d : Float;
		if(q<0) d = -IQTable.IQ_TABLE[-q];
		else d = IQTable.IQ_TABLE[q];
		return d;
	}

	/**
	 * gain = 2<sup>0.25*(sf-100)</sup>
	 */
	public static function computeGain(sf : Int) : Float
	{
		return GainTable.GAIN_TABLE[sf];
	}	
}