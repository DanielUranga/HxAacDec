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

package impl.gain;
import flash.Vector;
import impl.BitStream;
import impl.ICSInfo;
import impl.IntDivision;
import impl.VectorTools;

class GainControl 
{

	private var frameLen : Int;
	private var lbLong : Int;
	private var lbShort : Int;
	private var imdct : IMDCT;
	private var ipqf : IPQF;
	private var maxBand : Int;
	private var level : Vector<Vector<Vector<Int>>>;
	private var levelPrev : Vector<Vector<Vector<Int>>>;
	private var location : Vector<Vector<Vector<Int>>>;
	private var locationPrev : Vector<Vector<Vector<Int>>>;

	public function new(frameLen : Int)
	{
		this.frameLen = frameLen;
		lbLong = IntDivision.intDiv(frameLen, GCConstants.BANDS);
		lbShort = IntDivision.intDiv(lbLong, 8);
		imdct = new IMDCT(frameLen);
		//levelPrev = new int[0][][];
		levelPrev = new Vector<Vector<Vector<Int>>>(0);
		//locationPrev = new int[0][][];
		locationPrev = new Vector<Vector<Vector<Int>>>(0);
	}

	public function decode(input : BitStream, winSeq : WindowSequence)
	{
		maxBand = input.readBits(2)+1;
		//level = new int[maxBand][][];
		level = new Vector<Vector<Vector<Int>>>(maxBand);
		//location = new int[maxBand][][];
		location = new Vector<Vector<Vector<Int>>>(maxBand);

		var wdLen : Int;
		var locBits : Int;
		var locBits2 : Int = 0;
		switch(winSeq)
		{
			case WindowSequence.ONLY_LONG_SEQUENCE:
			{
				wdLen = 1;
				locBits = 5;
				locBits2 = 5;
			}
			case WindowSequence.EIGHT_SHORT_SEQUENCE:
			{
				wdLen = 8;
				locBits = 2;
				locBits2 = 2;
			}
			case WindowSequence.LONG_START_SEQUENCE:
			{
				wdLen = 2;
				locBits = 4;
				locBits2 = 2;
			}
			case WindowSequence.LONG_STOP_SEQUENCE:
			{
				wdLen = 2;
				locBits = 4;
				locBits2 = 5;
			}
		}

		//int wd, k, len, bits;
		var len : Int;
		var bits : Int;
		for (bd in 1...maxBand)
		{
			//level[bd] = new int[wdLen][];
			level[bd] = new Vector<Vector<Int>>(wdLen);
			//location[bd] = new int[wdLen][];
			location[bd] = new Vector<Vector<Int>>(wdLen);
			for (wd in 0...wdLen)
			{
				len = input.readBits(3);
				level[bd][wd] = new Vector<Int>(len);
				location[bd][wd] = new Vector<Int>(len);
				for (k in 0...len)
				{
					level[bd][wd][k] = input.readBits(4);
					bits = (wd==0) ? locBits : locBits2;
					location[bd][wd][k] = input.readBits(bits);
				}
			}
		}
	}

	public function process(data : Vector<Float>, winShape : Int, winShapePrev : Int, winSeq : WindowSequence)
	{
		var buf1 : Vector<Float> = new Vector<Float>(IntDivision.intDiv(frameLen, 2));
		//float[][] buf2 = new float[BANDS][lbLong];
		var buf2 = VectorTools.newMatrixVectorF(GCConstants.BANDS, lbLong);

		imdct.process(data, buf1, winShape, winShapePrev, winSeq);

		for (i in 0...GCConstants.BANDS)
		{
			compensate(buf1, buf2, winSeq, i);
		}

		ipqf.process(buf2, frameLen, maxBand, data);
	}

	/**
	 * gain compensation and overlap-add:
	 * - the gain control function is calculated
	 * - the gain control function applies to IMDCT output samples as a another IMDCT window
	 * - the reconstructed time domain signal produces by overlap-add
	 */
	private function compensate(input : Vector<Float>, out : Vector<Vector<Float>>, winSeq : WindowSequence, band : Int)
	{
		//final float[][] overlap = new float[BANDS][lbLong*2];
		var overlap : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(GCConstants.BANDS, lbLong*2);
		var window : Vector<Float> = new Vector<Float>(lbLong*2);

		if (winSeq == WindowSequence.EIGHT_SHORT_SEQUENCE)
		{
			var a : Int;
			var b : Int;
			for (k in 0...8)
			{
				//calculation
				calculateFunctionData(lbShort*2, band, window, winSeq, k);
				//applying
				for (j in 0...(lbShort * 2))
				{
					a = band*lbLong*2+k*lbShort*2+j;
					input[a] *= window[j];
				}
				//overlapping
				for (j in 0...lbShort)
				{
					a = j+IntDivision.intDiv(lbLong*7, 16)+lbShort*k;
					b = band*lbLong*2+k*lbShort*2+j;
					overlap[band][a] += input[b];
				}
				//store for next frame
				for (j in 0...lbShort)
				{
					a = j+IntDivision.intDiv(lbLong*7, 16)+lbShort*(k+1);
					b = band*lbLong*2+k*lbShort*2+lbShort+j;

					overlap[band][a] = input[b];
				}
				//locationPrev[band][0] = Arrays.copyOf(location[band][k], location[band][k].length);
				locationPrev[band][0] = VectorTools.copyOfI(location[band][k], location[band][k].length);
				//levelPrev[band][0] = Arrays.copyOf(level[band][k], level[band][k].length);
				levelPrev[band][0] = VectorTools.copyOfI(level[band][k], level[band][k].length);
			}
			//System.arraycopy(overlap[band], 0, out[band], 0, lbLong);
			VectorTools.vectorcopyF(overlap[band], 0, out[band], 0, lbLong);
			//System.arraycopy(overlap[band], lbLong, overlap[band], 0, lbLong);
			VectorTools.vectorcopyF(overlap[band], lbLong, overlap[band], 0, lbLong);
		}
		else
		{
			//calculation
			calculateFunctionData(lbLong*2, band, window, winSeq, 0);
			//applying
			for (j in 0...(lbLong * 2))
			{
				input[band*lbLong*2+j] *= window[j];
			}
			//overlapping
			for (j in 0...lbLong)
			{
				out[band][j] = overlap[band][j]+input[band*lbLong*2+j];
			}
			//store for next frame
			for (j in 0...lbLong)
			{
				overlap[band][j] = input[band*lbLong*2+lbLong+j];
			}
			var lastBlock : Int = (winSeq==WindowSequence.ONLY_LONG_SEQUENCE) ? 1 : 0;
			//locationPrev[band][0] = Arrays.copyOf(location[band][lastBlock], location[band][lastBlock].length);
			locationPrev[band][0] = VectorTools.copyOfI(location[band][lastBlock], location[band][lastBlock].length);
			//levelPrev[band][0] = Arrays.copyOf(level[band][lastBlock], level[band][lastBlock].length);
			levelPrev[band][0] = VectorTools.copyOfI(level[band][lastBlock], level[band][lastBlock].length);
		}
	}

	//produces gain control function data
	private function calculateFunctionData(samples : Int, band : Int, contrFunc : Vector<Float>, winSeq : WindowSequence, blockID : Int)
	{
		var locA : Vector<Int> = new Vector<Int>(10);
		var levA : Vector<Float> = new Vector<Float>(10);
		var modFunc : Vector<Float> = new Vector<Float>(samples);
		var buf1 : Vector<Float> = new Vector<Float>(IntDivision.intDiv(samples, 2));
		var buf2 : Vector<Float> = new Vector<Float>(IntDivision.intDiv(samples, 2));
		var buf3 : Vector<Float> = new Vector<Float>(IntDivision.intDiv(samples, 2));

		var maxLocGain0 : Int = 0;
		var maxLocGain1 : Int = 0;
		var maxLocGain2 : Int = 0;
		switch(winSeq)
		{
			case WindowSequence.ONLY_LONG_SEQUENCE, WindowSequence.EIGHT_SHORT_SEQUENCE:
			{
				maxLocGain0 = maxLocGain1 = IntDivision.intDiv(samples, 2);
				maxLocGain2 = 0;
			}
			case WindowSequence.LONG_START_SEQUENCE:
			{
				maxLocGain0 = IntDivision.intDiv(samples, 2);
				maxLocGain1 = IntDivision.intDiv(samples*7, 32);
				maxLocGain2 = IntDivision.intDiv(samples, 16);
			}
			case WindowSequence.LONG_STOP_SEQUENCE:
			{
				maxLocGain0 = IntDivision.intDiv(samples, 16);
				maxLocGain1 = IntDivision.intDiv(samples*7, 32);
				maxLocGain2 = IntDivision.intDiv(samples, 2);
			}
		}

		//calculate the fragment modification functions
		//for the first half region
		calculateFMD(band, 0, true, maxLocGain0, samples, locA, levA, buf1);

		//for the latter half region
		var block : Int = (winSeq==WindowSequence.EIGHT_SHORT_SEQUENCE) ? blockID : 0;
		var secLevel : Float = calculateFMD(band, block, false, maxLocGain1, samples, locA, levA, buf2);

		//for the non-overlapped region
		if (winSeq==WindowSequence.LONG_START_SEQUENCE || winSeq==WindowSequence.LONG_STOP_SEQUENCE)
		{
			calculateFMD(band, 1, false, maxLocGain2, samples, locA, levA, buf3);
		}

		//calculate a gain modification function
		var i : Int;
		var flatLen : Int = 0;
		if (winSeq == WindowSequence.LONG_STOP_SEQUENCE)
		{
			flatLen = IntDivision.intDiv(samples, 2)-maxLocGain0-maxLocGain1;
			for (i in 0...flatLen)
			{
				modFunc[i] = 1.0;
			}
		}
		if(winSeq==WindowSequence.ONLY_LONG_SEQUENCE || winSeq==WindowSequence.EIGHT_SHORT_SEQUENCE) levA[0] = 1.0;

		for (i in 0...maxLocGain0)
		{
			modFunc[i+flatLen] = levA[0]*secLevel*buf1[i];
		}
		for (i in 0...maxLocGain1)
		{
			modFunc[i+flatLen+maxLocGain0] = levA[0]*buf2[i];
		}

		if (winSeq==WindowSequence.LONG_START_SEQUENCE)
		{
			for (i in 0...maxLocGain2)
			{
				modFunc[i+maxLocGain0+maxLocGain1] = buf3[i];
			}
			flatLen = IntDivision.intDiv(samples, 2)-maxLocGain1-maxLocGain2;
			for (i in 0...flatLen)
			{
				modFunc[i+maxLocGain0+maxLocGain1+maxLocGain2] = 1.0;
			}
		}
		else if (winSeq == WindowSequence.LONG_STOP_SEQUENCE)
		{
			for (i in 0...maxLocGain2)
			{
				modFunc[i+flatLen+maxLocGain0+maxLocGain1] = buf3[i];
			}
		}

		//calculate a gain control function
		for (i in 0...samples)
		{
			contrFunc[i] = 1.0/modFunc[i];
		}
	}
	
	/*
	 * calculates a fragment modification function by interpolating the gain
	 * values of the gain change positions
	 */
	private function calculateFMD(bd : Int, wd : Int, prev : Bool, maxLocGain : Int, samples : Int,
			loc : Vector<Int>, lev : Vector<Float>, fmd : Vector<Float>) : Float
		{
		var m : Vector<Int> = new Vector<Int>(IntDivision.intDiv(samples, 2));
		var lct : Vector<Int> = prev ? locationPrev[bd][wd] : location[bd][wd];
		var lvl : Vector<Int> = prev ? levelPrev[bd][wd] : level[bd][wd];
		var length : Int = lct.length;

		var lngain : Int;
		for (i in 0...length)
		{
			loc[i+1] = 8*lct[i]; //gainc
			lngain = getGainChangePointID(lvl[i]); //gainc
			if(lngain<0) lev[i+1] = 1.0/Math.pow(2.0, -lngain);
			else lev[i+1] = Math.pow(2.0, lngain);
		}

		//set start point values
		loc[0] = 0;
		if(length==0) lev[0] = 1.0;
		else lev[0] = lev[1];
		var secLevel : Float = lev[0];

		//set end point values
		loc[length+1] = maxLocGain;
		lev[length+1] = 1.0;

		for (i in 0...maxLocGain)
		{
			m[i] = 0;
			for (j in 0...(length + 2))
			{
				if(loc[j]<=i) m[i] = j;
			}
		}

		for (i in 0...maxLocGain)
		{
			if((i>=loc[m[i]])&&(i<=loc[m[i]]+7)) fmd[i] = interpolateGain(lev[m[i]], lev[m[i]+1], i-loc[m[i]]);
			else fmd[i] = lev[m[i]+1];
		}

		return secLevel;
	}

	/**
	 * transformes the exponent value of the gain to the id of the gain change
	 * point
	 */
	private function getGainChangePointID(lngain : Int) : Int
	{
		for (i in 0...GCConstants.ID_GAIN)
		{
			if(lngain==GCConstants.LN_GAIN[i]) return i;
		}
		return 0; //shouldn't happen
	}

	/**
	 * calculates a fragment modification function
	 * the interpolated gain value between the gain values of two gain change
	 * positions is calculated by the formula:
	 * f(a,b,j) = 2^(((8-j)log2(a)+j*log2(b))/8)
	 */
	private function interpolateGain(alev0 : Float, alev1 : Float, iloc : Int) : Float
	{
		var a0 : Float = Math.log(alev0)/Math.log(2);
		var a1 : Float = Math.log(alev1)/Math.log(2);
		return Math.pow(2.0, (((8-iloc)*a0+iloc*a1)/8));
	}
	
}