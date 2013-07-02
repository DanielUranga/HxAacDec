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
	
package impl.noise;
import flash.Vector;
import impl.CPE;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntDivision;
import impl.IntMath;
import impl.SectionData;
import impl.stereo.MSMask;

class PNS 
{

	private static var PARITY  : Array<Int> = [
		0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
		1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
		1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
		0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
		1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0,
		0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
		0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1,
		1, 0, 0, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 0, 1, 0, 1, 1, 0, 1, 0, 0, 1, 1, 0, 0, 1, 0, 1, 1, 0
	];
	
	private static var r1 : Int = 1;
	private static var r2 : Int = 1;
	
	private function new()
	{
	}

	public static function processSingle(ics : ICStream, spec : Vector<Float>)
	{
		processCommon(ics, null, null, spec, null, false);
	}

	public static function processPair(cpe : CPE, specL : Vector<Float>, specR : Vector<Float>)
	{
		processCommon(cpe.getLeftChannel(), cpe.getRightChannel(), cpe, specL, specR, true);
	}

	private static function processCommon(icsL : ICStream, icsR : ICStream, cpe : CPE, specL : Vector<Float>, specR : Vector<Float>, channelPair : Bool)
	{
		var infoL : ICSInfo = icsL.getInfo();
		var windowGroupCount : Int = infoL.getWindowGroupCount();
		var maxSFB : Int = infoL.getMaxSFB();
		var sectDataL : SectionData = icsL.getSectionData();
		var swbOffsetsL : Vector<Int> = infoL.getSWBOffsets();
		var swbOffsetMaxL : Int = infoL.getSWBOffsetMax();
		var scaleFactorsL : Vector<Vector<Int>> = icsL.getScaleFactors();

		var shortFrameLen : Int = IntDivision.intDiv(specL.length, 8);

		var infoR : ICSInfo = null;
		var sectDataR : SectionData = null;
		var swbOffsetsR : Vector<Int> = null;
		var swbOffsetMaxR : Int = 0;
		var scaleFactorsR : Vector<Vector<Int>> = null;
		if (icsR != null)
		{
			infoR = icsR.getInfo();
			sectDataR = icsR.getSectionData();
			swbOffsetsR = infoR.getSWBOffsets();
			swbOffsetMaxR = infoR.getSWBOffsetMax();
			scaleFactorsR = icsR.getScaleFactors();
		}

		var msMask : MSMask = null;
		if(cpe!=null) msMask = cpe.getMSMask();

		var sfb : Int;
		var size : Int;
		var offs : Int;
		var win : Int = 0;

		for (g in 0...windowGroupCount)
		{
			for (b in 0...infoL.getWindowGroupLength(g))
			{
				for (sfb in 0...maxSFB)
				{
					if (sectDataL.isNoise(g, sfb))
					{
						infoL.unsetPredictionSFB(sfb);

						offs = swbOffsetsL[sfb];
						size = IntMath.min(swbOffsetsL[sfb+1], swbOffsetMaxL)-offs;

						generateRandomVector(specL, (win*shortFrameLen)+offs, size, scaleFactorsL[g][sfb]);
					}

					if (channelPair && sectDataR.isNoise(g, sfb))
					{
						if((msMask==MSMask.TYPE_USED&&(cpe.isMSUsed(g, sfb)))
								||(msMask==MSMask.TYPE_ALL_1))
						{
							offs = swbOffsetsR[sfb];
							size = IntMath.min(swbOffsetsR[sfb+1], swbOffsetMaxR)-offs;

							for (c in 0...size)
							{
								specR[(win*shortFrameLen)+offs+c] = specR[(win*shortFrameLen)+offs+c];
							}
						}
						else
						{
							infoR.unsetPredictionSFB(sfb);

							offs = swbOffsetsR[sfb];
							size = IntMath.min(swbOffsetsR[sfb+1], swbOffsetMaxR)-offs;

							generateRandomVector(specR, (win*shortFrameLen)+offs, size, scaleFactorsR[g][sfb]);
						}
					}
				}
				win++;
			}
		}
	}

	private static function generateRandomVector(spec : Vector<Float>, off : Int, size : Int, sf : Int)
	{
		var energy : Float = 0.0;

		var scale : Float = 1.0/size;

		var tmp : Float;
		for (i in 0...size)
		{
			tmp = scale*nextRandom();
			spec[off+i] = tmp;
			energy += tmp*tmp;
		}

		scale = 1.0/Math.sqrt(energy);
		scale *= Math.pow(2.0, 0.25*sf);
		for (i in 0...size)
		{
			spec[off+i] *= scale;
		}
	}

	//random number generator based on parity table
	private static function nextRandom() : Int
	{
		var t1 : Int = r1;
		var t3 : Int = r1;
		var t2 : Int = r2;
		var t4 : Int = r2;
		t1 &= 0xF5;
		t2 >>= 25;
		t1 = PARITY[t1];
		t2 &= 0x63;
		t1 <<= 31;
		t2 = PARITY[t2];
		r1 = (t3>>1)|t1;
		r2 = (t4+t4)|t2;

		return r1^r2;
	}
	
}