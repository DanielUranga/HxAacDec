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
import impl.huffman.Huffman;

class CCE extends Element
{

	public static inline var BEFORE_TNS : Int = 0;
	public static inline var AFTER_TNS : Int = 1;
	public static inline var AFTER_IMDCT : Int = 2;
	private static var CCE_SCALE : Array<Float> = [
		1.09050773266525765921,
		1.18920711500272106672,
		1.4142135623730950488016887,
		2];
	private var ics : ICStream;
	private var iqData : Vector<Float>;
	private var couplingPoint : Int;
	private var coupledCount : Int;
	private var channelPair : Vector<Bool>;
	private var idSelect : Vector<Int>;
	private var chSelect : Vector<Int>;
	/*[0] shared list of gains; [1] list of gains for right channel;
	 *[2] list of gains for left channel; [3] lists of gains for both channels
	 */
	private var gain : Vector<Vector<Float>>;
	private var huffman : Huffman;

	public function new(huff : Huffman, frameLength : Int)
	{
		//super();
		huffman = huff;
		ics = new ICStream(huffman, frameLength);
		channelPair = new Vector<Bool>(8);
		idSelect = new Vector<Int>(8);
		chSelect = new Vector<Int>(8);
		//gain = new float[16][120];
		gain = VectorTools.newMatrixVectorF(16, 120);		
	}

	public function getCouplingPoint() : Int
	{
		return couplingPoint;
	}

	public function getCoupledCount() : Int
	{
		return coupledCount;
	}

	public function isChannelPair(index : Int) : Bool
	{
		return channelPair[index];
	}

	public function getIDSelect(index : Int) : Int
	{
		return idSelect[index];
	}

	public function getCHSelect(index : Int) : Int
	{
		return chSelect[index];
	}

	public function decode(input : BitStream, conf : DecoderConfig)
	{
		couplingPoint = 2*input.readBit();
		coupledCount = input.readBits(3);
		var gainCount : Int = 0;
		for (i in 0...(coupledCount+1))
		{
			gainCount++;
			channelPair[i] = input.readBool();
			idSelect[i] = input.readBits(4);
			if (channelPair[i])
			{
				chSelect[i] = input.readBits(2);
				if(chSelect[i]==3) gainCount++;
			}
			else chSelect[i] = 2;
		}
		couplingPoint += input.readBit();
		couplingPoint |= (couplingPoint>>1);

		var sign : Bool = input.readBool();
		var scale : Float = CCE_SCALE[input.readBits(2)];

		ics.decode(input, false, conf);
		var info : ICSInfo = ics.getInfo();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var maxSFB : Int = info.getMaxSFB();
		var sfbCB : Vector<Vector<Int>> = ics.getSectionData().getSfbCB();

		for (i in 0...gainCount)
		{
			var idx : Int = 0;
			var cge : Int = 1;
			var xg : Int = 0;
			var gainCache : Float = 1.0;
			if(i>0) {
				cge = couplingPoint==2 ? 1 : input.readBit();
				xg = cge!=0 ? huffman.decodeScaleFactor(input)-60 : 0;
				gainCache = Math.pow(scale, -xg);
			}
			if(couplingPoint==2) gain[i][0] = gainCache;
			else
			{
				var sfb : Int;
				for (g in 0...windowGroupCount)
				{
					for (sfb in 0...maxSFB)
					{
						if (sfbCB[g][sfb] != HCB.ZERO_HCB)
						{
							if (cge == 0)
							{
								var t : Int = huffman.decodeScaleFactor(input)-60;
								if (t != 0)
								{
									var s : Int = 1;
									t = xg += t;
									if (!sign)
									{
										s -= 2*(t&0x1);
										t >>= 1;
									}
									gainCache = Math.pow(scale, -t)*s;
								}
							}
							gain[i][idx] = gainCache;
						}
						idx++;
					}
				}
			}
		}
	}

	public function process()
	{
		iqData = ics.getInvQuantData();
	}

	public function applyIndependentCoupling(index : Int, data : Vector<Float>)
	{
		var g : Float = gain[index][0];
		for (i in 0...data.length)
		{
			data[i] += g*iqData[i];
		}
	}

	public function applyDependentCoupling(index : Int, data : Vector<Float>)
	{
		var info : ICSInfo = ics.getInfo();
		var swbOffsets : Vector<Int> = info.getSWBOffsets();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var maxSFB : Int = info.getMaxSFB();
		var sfbCB : Vector<Vector<Int>> = ics.getSectionData().getSfbCB();

		var srcOff : Int = 0;
		var dstOff : Int = 0;

		var len : Int;
		var sfb : Int;
		var group : Int;
		var k : Int;
		var idx : Int = 0;
		var x : Float;
		for (g in 0...windowGroupCount)
		{
			len = info.getWindowGroupLength(g);
			for (sfb in 0...maxSFB)
			{
				if (sfbCB[g][sfb] != HCB.ZERO_HCB)
				{
					x = gain[index][idx];
					for (group in 0...len)
					{
						for (k in swbOffsets[sfb]...swbOffsets[sfb + 1])
						{
							data[dstOff+group*128+k] += x*iqData[srcOff+group*128+k];
						}
					}
				}
				idx++;
			}
			dstOff += len*128;
			srcOff += len*128;
		}
	}
	
}