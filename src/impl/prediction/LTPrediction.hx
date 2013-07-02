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
	
package impl.prediction;
import flash.Vector;
import impl.BitStream;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntMath;
import impl.Constants;
import impl.filterbank.FilterBank;
import impl.VectorTools;

class LTPrediction 
{
	
	private var CODEBOOK : Array<Float>;
	private var frameLength : Int;
	private var states : Vector<Int>;
	private var coef : Int;
	private var lag : Int;
	private var lastBand : Int;
	private var lagUpdate : Bool;
	private var shortUsed : Vector<Bool>;
	private var shortLagPresent : Vector<Bool>;
	private var longUsed : Vector<Bool>;
	private var shortLag : Vector<Int>;
	
	public function new(frameLength : Int)
	{
		this.frameLength = frameLength;
		states = new Vector<Int>(4*frameLength);
		shortUsed = null;
		shortLagPresent = null;
		longUsed = null;
		shortLag = null;
		CODEBOOK = [
			0.570829,
			0.696616,
			0.813004,
			0.911304,
			0.984900,
			1.067894,
			1.194601,
			1.369533
		];
	}
	
	public function decode(input : BitStream, info : ICSInfo, profile : Profile)
	{
		lag = 0;
		if (profile==Profile.AAC_LD)
		{
			lagUpdate = input.readBool();
			if (lagUpdate)
			{
				lag = input.readBits(10);
			}
		}
		else
		{
			lag = input.readBits(11);
		}
		if(lag>(frameLength<<1)) throw("LTP lag too large: "+lag);
		coef = input.readBits(3);
		var windowCount : Int = info.getWindowCount();
		if (info.isEightShortFrame())
		{
			shortUsed = new Vector<Bool>(windowCount);
			shortLagPresent = new Vector<Bool>(windowCount);
			shortLag = new Vector<Int>(windowCount);
			for (w in 0...windowCount)
			{
				if ((shortUsed[w] = input.readBool()))
				{
					shortLagPresent[w] = input.readBool();
					if (shortLagPresent[w])
					{
						shortLag[w] = input.readBits(4);
					}
				}
			}
		}
		else
		{
			lastBand = IntMath.min(info.getMaxSFB(), Constants.MAX_LTP_SFB);
			longUsed = new Vector<Bool>(lastBand);
			for (i in 0...lastBand)
			{
				longUsed[i] = input.readBool();
			}
		}
	}
	
	public inline function setPredictionUnused(sfb : Int)
	{
		if(longUsed!=null) longUsed[sfb] = false;
	}
	
	public function process(ics : ICStream, data : Vector<Float>, filterBank : FilterBank, sf :  SampleFrequency)
	{
		var info : ICSInfo = ics.getInfo();
		if (!info.isEightShortFrame())
		{
			var samples : Int = frameLength<<1;
			var input : Vector<Float> = new Vector<Float>(2048);
			var out : Vector<Float> = new Vector<Float>(2048);
			for (i in 0...samples)
			{
				input[i] = states[samples+i-lag]*CODEBOOK[coef];
			}
			filterBank.processLTP(info.getWindowSequence(), info.getWindowShape(ICSInfo.CURRENT),
					info.getWindowShape(ICSInfo.PREVIOUS), input, out);
			if(ics.isTNSDataPresent()) ics.getTNS().process(ics, out, sf, true);
			var swbOffsets : Vector<Int> = info.getSWBOffsets();
			var swbOffsetMax : Int = info.getSWBOffsetMax();
			var low : Int;
			var high : Int;
			var bin : Int;
			for (sfb in 0...lastBand)
			{
				if (longUsed[sfb])
				{
					low = swbOffsets[sfb];
					high = IntMath.min(swbOffsets[sfb+1], swbOffsetMax);
					for (bin in low...high)
					{
						data[bin] += out[bin];
					}
				}
			}
		}
	}
	
	public function updateState(time : Vector<Float>, overlap : Vector<Float>, profile : Profile)
	{
		if (profile==Profile.AAC_LD)
		{
			for (i in 0...frameLength)
			{
				states[i] = states[i+frameLength];
				states[frameLength+i] = states[i+(frameLength*2)];
				states[(frameLength*2)+i] = Math.round(time[i]);
				states[(frameLength*3)+i] = Math.round(overlap[i]);
			}
		}
		else
		{
			for (i in 0...frameLength)
			{
				states[i] = states[i+frameLength];
				states[frameLength+i] = Math.round(time[i]);
				states[(frameLength*2)+i] = Math.round(overlap[i]);
			}
		}
	}

	public static function isLTPProfile(profile : Profile) : Bool
	{
		return profile==Profile.AAC_LTP||profile==Profile.ER_AAC_LTP||profile==Profile.AAC_LD;
	}

	public function copy(ltp : LTPrediction)
	{
		//System.arraycopy(ltp.states, 0, states, 0, states.length);
		VectorTools.vectorcopyI(ltp.states, 0, states, 0, states.length);
		coef = ltp.coef;
		lag = ltp.lag;
		lastBand = ltp.lastBand;
		lagUpdate = ltp.lagUpdate;
		//shortUsed = Arrays.copyOf(ltp.shortUsed, ltp.shortUsed.length);
		shortUsed = VectorTools.copyOfB(ltp.shortUsed, ltp.shortUsed.length);
		//shortLagPresent = Arrays.copyOf(ltp.shortLagPresent, ltp.shortLagPresent.length);
		shortLagPresent = VectorTools.copyOfB(ltp.shortLagPresent, ltp.shortLagPresent.length);
		//shortLag = Arrays.copyOf(ltp.shortLag, ltp.shortLag.length);
		shortLag = VectorTools.copyOfI(ltp.shortLag, ltp.shortLag.length);
		//longUsed = Arrays.copyOf(ltp.longUsed, ltp.longUsed.length);
		longUsed = VectorTools.copyOfB(ltp.longUsed, ltp.longUsed.length);
	}
	
}