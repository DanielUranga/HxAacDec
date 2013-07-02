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

package impl.sbr;

import flash.Vector;
import impl.IntMath;
import impl.VectorTools;

class Calculation 
{
	
	public static function getStartChannel(startFrequency : Int, sampleRate : Int) : Int
	{
		var index : Int = getSampleRateIndex(sampleRate);
		var startMin : Int = SBRTables.START_MIN_TABLE[index];
		var offsetIndex : Int = SBRTables.OFFSET_INDEX_TABLE[index];
		return startMin+SBRTables.START_OFFSETS[offsetIndex][startFrequency];
	}

	public static function getStopChannel(stopFrequency : Int, sampleRate : Int, k0 : Int) : Int
	{
		if(stopFrequency==15) return IntMath.min(64, k0*3);
		else if(stopFrequency==14) return IntMath.min(64, k0*2);
		else
		{
			//stopFrequency<=13
			var index : Int = getSampleRateIndex(sampleRate);
			var stopMin : Int = SBRTables.STOP_MIN_TABLE[index];
			return IntMath.min(64, stopMin+SBRTables.STOP_OFFSETS[index][IntMath.min(stopFrequency, 13)]);
		}
	}

	//TODO: replace with SampleFrequency.forFrequency ??
	public static function getSampleRateIndex(samplerate : Int) : Int
	{
		if(92017<=samplerate) return 0;
		else if(75132<=samplerate) return 1;
		else if(55426<=samplerate) return 2;
		else if(46009<=samplerate) return 3;
		else if(37566<=samplerate) return 4;
		else if(27713<=samplerate) return 5;
		else if(23004<=samplerate) return 6;
		else if(18783<=samplerate) return 7;
		else if(13856<=samplerate) return 8;
		else if(11502<=samplerate) return 9;
		else if(9391<=samplerate) return 10;
		else return 11;
	}
	
	public static function calculateMasterFrequencyTableFS0(k0 : Int, k2 : Int, alterScale : Bool) : Vector<Int>
	{
		if(k2<=k0) return null;
		var dk : Int = alterScale ? 2 : 1;
		var i : Int;
		var nrBands : Int = alterScale ? (((k2-k0+2)>>2)<<1) : (((k2-k0)>>1)<<1);
		nrBands = IntMath.min(nrBands, 63);
		if (nrBands <= 0) return new Vector<Int>(0);
		var k2Achieved : Int = k0+nrBands*dk;
		var k2Diff : Int = k2-k2Achieved;
		//fill vDk
		var vDk : Vector<Int> = new Vector<Int>(64);
		for (i in 0...nrBands)
		{
			vDk[i] = dk;
		}
		if (k2Diff != 0)
		{
			var incr : Int = (k2Diff>0) ? -1 : 1;
			i = ((k2Diff>0) ? (nrBands-1) : 0);
			while (k2Diff != 0)
			{
				vDk[i] -= incr;
				i += incr;
				k2Diff += incr;
			}
		}
		//fill table
		var len : Int = IntMath.min(nrBands+1, 64);
		var table : Vector<Int> = new Vector<Int>(len);
		table[0] = k0;
		for (i in 1...len)
		{
			table[i] = table[i-1]+vDk[i-1];
		}
		return table;
	}
	
	/* finds the number of bands by:
	 * bands * log(a1/a0)/log(2.0) + 0.5 */
	public static inline function findBands(warp : Bool, bands : Int, a0 : Int, a1 : Int) : Int
	{
		var div : Float = 0.693147180559945309417232;//Math.log(2.0);
		if (warp) div *= 1.3;
		return Std.int(bands * Math.log(a1 / a0) / div + 0.5);
	}
	
	private static inline function findInitialPower(bands : Int, a0 : Int, a1 : Int) : Float
	{
		return Math.pow(a1/a0, 1.0/bands);
	}
	
	public static function calculateMasterFrequencyTable(k0 : Int, k2 : Int, frequencyScale : Int, alterScale : Bool) : Vector<Int>
	{
		if(k2<=k0) return null;
		var bands : Int = SBRTables.MFT_BANDS_COUNT[frequencyScale-1];
		var i : Int;
		var k1 : Int;
		var twoRegions : Bool;
		if ((k2/k0) > 2.2449)
		{
			twoRegions = true;
			k1 = k0<<1;
		}
		else
		{
			twoRegions = false;
			k1 = k2;
		}		
		var nrBand0 : Int = IntMath.min(2*findBands(false, bands, k0, k1), 63);
		if(nrBand0<=0) return new Vector<Int>(0);
		//fill vDk0
		var vDk0 : Vector<Int> = new Vector<Int>(64);
		var q : Float = findInitialPower(nrBand0, k0, k1);
		var qk : Float = k0;
		var A_1 : Int = Std.int(qk+0.5);
		var A_0 : Int;
		for ( i in 0...nrBand0+1 )
		{
			A_0 = A_1;
			qk *= q;
			A_1 = Math.round(qk);
			vDk0[i] = A_1-A_0;
		}
		//Arrays.sort(vDk0, 0, nrBand0); //needed??
		VectorTools.sortI(vDk0, 0, nrBand0);
		//fill vk0
		var vk0 : Vector<Int> = new Vector(64);
		vk0[0] = k0;
		for ( i in 1...nrBand0+1 )
		{
			vk0[i] = vk0[i-1]+vDk0[i-1];
			if(vDk0[i-1]==0) return new Vector<Int>(0);
		}
		var ret : Vector<Int> = new Vector<Int>();
		if (twoRegions)
		{
			//two region: create vk1 and append it to vk0
			var nrBand1 : Int = IntMath.min(2*findBands(true, bands, k1, k2), 63);
			//fill vDk1
			var vDk1 : Vector<Int> = new Vector<Int>(64);
			q = findInitialPower(nrBand1, k1, k2);
			qk = k1;
			A_1 = Std.int(qk+.5);
			for ( i in 0...nrBand0+1 )
			{
				A_0 = A_1;
				qk *= q;
				A_1 = Std.int(qk+0.5);
				vDk1[i] = A_1-A_0;
			}
			if(vDk1[0]<vDk0[nrBand0-1]) {
				//Arrays.sort(vDk1, 0, nrBand1+1); //needed??
				VectorTools.sortI(vDk1, 0, nrBand1+1);
				var change : Int = vDk0[nrBand0-1]-vDk1[0];
				vDk1[0] = vDk0[nrBand0-1];
				vDk1[nrBand1-1] = vDk1[nrBand1-1]-change;
			}
			//fill vk1
			var vk1 : Vector<Int> = new Vector<Int>(64);
			//Arrays.sort(vDk1, 0, nrBand1); //needed??
			VectorTools.sortI(vDk1, 0, nrBand1);
			vk1[0] = k1;
			for ( i in 1...nrBand1+1 )
			{
				vk1[i] = vk1[i-1]+vDk1[i-1];
				if(vDk1[i-1]==0) return new Vector<Int>(0);
			}
			var off : Int = nrBand0+1;
			var len : Int = IntMath.min(off+nrBand1, 64);
			ret = new Vector<Int>(len);
			VectorTools.vectorcopyI(vk0,0,ret,0,off);
			VectorTools.vectorcopyI(vk1,1,ret,off,nrBand1);
		}
		else
		{
			//one region: just copy vk0
			var len : Int = IntMath.min(nrBand0+1, 64);
			ret = new Vector<Int>(len);
			VectorTools.vectorcopyI(vk0,0,ret,0,len);
		}
		return ret;
	}
	
}