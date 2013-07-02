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

package impl.stereo;
import flash.Vector;
import impl.CPE;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntDivision;
import impl.IntMath;
import impl.SectionData;

class MS 
{

	private function MS()
	{
	}

	public static function process(cpe : CPE, specL : Vector<Float>, specR : Vector<Float>)
	{
		var msMask : MSMask = cpe.getMSMask();
		var icsL : ICStream = cpe.getLeftChannel();
		var icsR : ICStream = cpe.getRightChannel();
		var infoL : ICSInfo = icsL.getInfo();
		var sectDataL : SectionData = icsL.getSectionData();
		var sectDataR = icsR.getSectionData();
		var windowGroupCount : Int = infoL.getWindowGroupCount();
		var maxSFB : Int = infoL.getMaxSFB();
		var swbOffsets : Vector<Int> = infoL.getSWBOffsets();
		var swbOffsetMax : Int = infoL.getSWBOffsetMax();

		var shortFrameLen : Int = IntDivision.intDiv(specL.length, 8);
		
		var off : Int = 0;
		var k : Int;
		var i : Int;
		var l : Float;
		var r : Float;

		for (g in 0...windowGroupCount)
		{
			for (b in 0...infoL.getWindowGroupLength(g))
			{
				for (sfb in 0...maxSFB)
				{
					if((cpe.isMSUsed(g, sfb)||msMask==MSMask.TYPE_ALL_1)
							&&(sectDataR.isIntensity(g, sfb) == 0) && !sectDataL.isNoise(g, sfb))
					{
						i = swbOffsets[sfb];
						while (i < IntMath.min(swbOffsets[sfb + 1], swbOffsetMax))
						{
							k = (off * shortFrameLen) + i;
							l = specL[k];
							r = specR[k];
							specL[k] = r + l;
							specR[k] = l - r;
							i++;
						}
					}
				}
				off++;
			}
		}
	}
	
}