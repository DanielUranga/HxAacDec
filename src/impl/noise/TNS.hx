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
import impl.BitStream;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntDivision;
import impl.IntMath;

class TNS 
{

	private static var TNS_MAX_ORDER : Int = 20;
	private static var SHORT_BITS : Array<Int> = [1, 4, 3];
	private static var LONG_BITS : Array<Int> = [2, 6, 5];
	//bitstream
	private var nFilt : Vector<Int>;
	private var coefRes : Vector<Int>;	// Should be Vector<Byte>
	private var length : Vector<Vector<Int>>;
	private var order : Vector<Vector<Int>>;
	private var coefCompress : Vector<Vector<Int>>;	// Should be Vector<Vector<Byte>>
	private var direction : Vector<Vector<Bool>>;
	private var coef : Vector<Vector<Vector<Int>>>;	// Should be Vector<Vector<Vector<Byte>>>
	//processing buffers
	private var lpc : Vector<Float>;
	private var tmp1 : Vector<Float>;
	private var tmp2 : Vector<Float>;
	
	public function new() 
	{
		lpc = new Vector<Float>(TNS_MAX_ORDER+1);
		tmp1 = new Vector<Float>(TNS_MAX_ORDER+1);
		tmp2 = new Vector<Float>(TNS_MAX_ORDER+1);
	}
	
	public function decode(input : BitStream, info : ICSInfo)
	{
		var windowCount : Int = info.getWindowCount();
		var bits : Array<Int> = info.isEightShortFrame() ? SHORT_BITS : LONG_BITS;
		var filt : Int;
		var i : Int;
		var coefBits : Int;
		var coefLen : Int;
		nFilt = new Vector<Int>(windowCount);
		coefRes = new Vector<Int>(windowCount);
		length = new Vector<Vector<Int>>(windowCount);
		order = new Vector<Vector<Int>>(windowCount);
		coefCompress = new Vector<Vector<Int>>(windowCount);
		direction = new Vector<Vector<Bool>>(windowCount);
		coef = new Vector<Vector<Vector<Int>>>(windowCount);
		for (w in 0...windowCount)
		{
			if ((nFilt[w] = input.readBits(bits[0])) != 0)
			{
				length[w] = new Vector<Int>(nFilt[w]);
				order[w] = new Vector<Int>(nFilt[w]);
				direction[w] = new Vector<Bool>(nFilt[w]);
				coefCompress[w] = new Vector<Int>(nFilt[w]);
				coef[w] = new Vector<Vector<Int>>(nFilt[w]);
				coefRes[w] = input.readBit();
				coefBits = 3+coefRes[w];
				for (filt in 0...nFilt[w])
				{
					length[w][filt] = input.readBits(bits[1]);
					if((order[w][filt] = input.readBits(bits[2]))>TNS_MAX_ORDER) throw("TNS filter order out of range: "+order[w][filt]);
					if (order[w][filt] != 0)
					{
						coef[w][filt] = new Vector<Int>(order[w][filt]);
						direction[w][filt] = input.readBool();
						coefCompress[w][filt] = input.readBit();
						coefLen = coefBits-coefCompress[w][filt];
						for (i in 0...order[w][filt])
						{
							coef[w][filt][i] = input.readBits(coefLen);
						}
					}
				}
			}
		}
	}
	
	public function process(ics : ICStream, spec : Vector<Float>, sf : SampleFrequency, forward : Bool)
	{
		var info : ICSInfo = ics.getInfo();
		var maxSFB : Int = info.getMaxSFB();
		var windowCount : Int = info.getWindowCount();
		var swbCount : Int = info.getSWBCount();
		var swbOffsets : Vector<Int> = info.getSWBOffsets();
		var swbOffsetMax : Int = info.getSWBOffsetMax();
		var maxTNSSFB : Int = sf.getMaximalTNS_SFB(info.isEightShortFrame());

		var shortFrameLen : Int = IntDivision.intDiv(spec.length,8);

		var f : Int;
		var tnsOrder : Int;
		var inc : Int;
		var size : Int;
		var bottom : Int;
		var top : Int;
		var start : Int;
		var end : Int;

		for (w in 0...windowCount)
		{
			bottom = swbCount;
			for (f in 0...nFilt[w])
			{
				top = bottom;
				bottom = IntMath.max(top-length[w][f], 0);
				tnsOrder = IntMath.min(order[w][f], TNS_MAX_ORDER);
				if(tnsOrder==0) continue;

				decodeCoef(coef[w][f], tnsOrder, coefRes[w], coefCompress[w][f]);

				start = IntMath.min(bottom, maxTNSSFB);
				start = IntMath.min(start, maxSFB);
				start = IntMath.min(swbOffsets[start], swbOffsetMax);

				end = IntMath.min(top, maxTNSSFB);
				end = IntMath.min(end, maxSFB);
				end = IntMath.min(swbOffsets[end], swbOffsetMax);

				size = end-start;
				if(size<=0) continue;

				if (direction[w][f])
				{
					inc = -1;
					start = end-1;
				}
				else
				{
					inc = 1;
				}

				if(forward) applyZeroFilter(spec, (w*shortFrameLen)+start, size, inc, tnsOrder);
				else applyPoleFilter(spec, (w*shortFrameLen)+start, size, inc, tnsOrder);
			}
		}
	}
	
	//decodes coefs in input array and stores them in lpc-buffer
	private function decodeCoef(input : Vector<Int>, order : Int, coefRes : Int, coefCompress : Int)
	{
		var i : Int;

		//conversion to TNS coefs
		var table : Array<Float> = TNSTables.TNS_TABLES[2*coefCompress+coefRes];
		for (i in 0...order)
		{
			tmp1[i] = table[input[i]];
		}

		//conversion to LPC coefs
		lpc[0] = 1.0;
		for (m in 1...order+1)
		{
			for (i in 1...m)
			{
				tmp2[i] = lpc[i]+(tmp1[m-1]*lpc[m-i]);
			}
			for (i in 1...m)
			{
				lpc[i] = tmp2[i];
			}
			lpc[m] = tmp1[m-1];
		}
	}
	
	private function applyZeroFilter(spec : Vector<Float>, off : Int, size : Int, inc : Int, order : Int)
	{
		var y : Float;
		var state : Vector<Float> = new Vector<Float>(2*TNS_MAX_ORDER);
		var index : Int = 0;
		for (i in 0...size)
		{
			y = spec[off];
			for (j in 0...order)
			{
				y += state[index+j]*lpc[j+1];
			}
			index--;
			if(index<0) index = order-1;
			state[index] = spec[off];
			state[index+order] = spec[off];
			spec[off] = y;
			off += inc;
		}
	}
	
	private function applyPoleFilter(spec : Vector<Float>, off : Int, size : Int, inc : Int, order : Int)
	{
		var state : Vector<Float> = new Vector<Float>(2*TNS_MAX_ORDER);
		var index : Int = 0;
		var y : Float;
		for (i in 0...size)
		{
			y = spec[off];
			for (j in 0...order)
			{
				y -= state[index+j]*lpc[j+1];
			}
			index--;
			if(index<0) index = order-1;
			state[index] = y;
			state[index+order] = y;
			spec[off] = y;
			off += inc;
		}
	}
	
}