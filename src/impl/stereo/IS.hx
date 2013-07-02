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
import impl.prediction.ICPrediction;
import impl.SectionData;

class IS 
{

	private function new()
	{
	}

	public static function process(cpe : CPE, specL : Vector<Float>, specR : Vector<Float>)
	{
		var icsL : ICStream = cpe.getLeftChannel();
		var icsR : ICStream = cpe.getRightChannel();
		var infoL : ICSInfo = icsL.getInfo();
		var infoR : ICSInfo = icsR.getInfo();
		var sectDataR : SectionData = icsR.getSectionData();
		var windowGroupCount : Int = infoR.getWindowGroupCount();
		var maxSFB : Int = infoR.getMaxSFB();
		var scaleFactors : Vector<Vector<Int>> = icsR.getScaleFactors();
		var swbOffsets : Vector<Int> = infoR.getSWBOffsets();
		var swbOffsetMax : Int = infoL.getSWBOffsetMax();
		var predL : ICPrediction = infoL.getICPrediction();
		var predR : ICPrediction = infoR.getICPrediction();

		var shortFrameLen : Int = IntDivision.intDiv(specL.length, 8);

		var max : Int;
		var scale : Float;
		var group : Int = 0;

		for (g in 0...windowGroupCount)
		{
			for (b in 0...infoR.getWindowGroupLength(g))
			{
				for (sfb in 0...maxSFB)
				{
					max = IntMath.min(swbOffsets[sfb+1], swbOffsetMax);
					if (sectDataR.isIntensity(g, sfb) != 0)
					{
						predL.setPredictionUnused(sfb);
						predR.setPredictionUnused(sfb);

						scale = ISScaleTable.SCALE_TABLE[scaleFactors[g][sfb]];

						for (i in swbOffsets[sfb]...max)
						{
							specR[(group*shortFrameLen)+i] = specL[(group*shortFrameLen)+i]*scale;
							if(sectDataR.isIntensity(g, sfb)!=invertIntensity(cpe, g, sfb)) specR[(group*shortFrameLen)+i] = -specR[(group*shortFrameLen)+i];
						}
					}
				}
				group++;
			}
		}
	}

	private static function invertIntensity(cpe : CPE, g : Int, sfb : Int) : Int
	{
		var i : Int;
		if(cpe.getMSMask()==MSMask.TYPE_USED) i = (1-2*(cpe.isMSUsed(g, sfb) ? 1 : 0));
		else i = 1;
		return i;
	}
	
}