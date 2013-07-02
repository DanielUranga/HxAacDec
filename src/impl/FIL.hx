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

class DynamicRangeInfo
{

	public static var MAX_NBR_BANDS : Int = 7;
	public var excludeMask : Vector<Bool>;
	public var additionalExcludedChannels : Vector<Bool>;
	public var pceTagPresent : Bool;
	public var pceInstanceTag : Int;
	public var tagReservedBits : Int;
	public var excludedChannelsPresent : Bool;
	public var bandsPresent : Bool;
	public var bandsIncrement : Int;
	public var interpolationScheme : Int;
	public var bandTop : Vector<Int>;
	public var progRefLevelPresent : Bool;
	public var progRefLevel : Int;
	public var progRefLevelReservedBits : Int;
	public var dynRngSgn : Vector<Bool>;
	public var dynRngCtl : Vector<Int>;

	public function new()
	{
		excludeMask = new Vector<Bool>(MAX_NBR_BANDS);
		additionalExcludedChannels = new Vector<Bool>(MAX_NBR_BANDS);
	}
}
 
class FIL extends Element
{
	private static var TYPE_FILL : Int = 0;
	private static var TYPE_FILL_DATA : Int = 1;
	private static var TYPE_EXT_DATA_ELEMENT : Int = 2;
	private static var TYPE_DYNAMIC_RANGE : Int = 11;
	private static var TYPE_SBR_DATA : Int = 13;
	private static var TYPE_SBR_DATA_CRC : Int = 14;
	private var dri : DynamicRangeInfo;
	private var downSampledSBR : Bool;

	public function new(downSampledSBR : Bool)
	{
		//super();
		this.downSampledSBR = downSampledSBR;
	}

	public function decode(input : BitStream, prev : Element, sf : SampleFrequency)
	{
		var count : Int = input.readBits(4);
		if(count==15) count += input.readBits(8)-1;
		count *= 8; //convert to bits

		var cpy : Int = count;
		var pos : Int = input.getPosition();

		while (count > 0)
		{
			count = decodeExtensionPayload(input, count, prev, sf);
		}

		var pos2 : Int = input.getPosition()-pos;
		var bitsLeft : Int = cpy-pos2;
		if(bitsLeft>0) input.skipBits(pos2);
		else if(bitsLeft<0) throw("FIL element overread: "+bitsLeft);
	}

	private function decodeExtensionPayload(input : BitStream, count : Int, prev : Element, sf : SampleFrequency) : Int
	{
		var type : Int = input.readBits(4);
		count -= 4;
		switch(type)
		{
			case x if (x==TYPE_DYNAMIC_RANGE):
			{
				count = decodeDynamicRangeInfo(input, count);
			}
			case x if (x==TYPE_SBR_DATA || x==TYPE_SBR_DATA_CRC):
			{
				if (Std.is(prev, SCE_LFE) || Std.is(prev, CPE) || Std.is(prev, CCE))
				{
					prev.decodeSBR(input, sf, count, Std.is(prev, CPE), (type == TYPE_SBR_DATA_CRC), downSampledSBR);
					count = 0;			
				}
				else throw("SBR applied on unexpected element: " + prev);
			}
			/*case TYPE_FILL, TYPE_FILL_DATA, TYPE_EXT_DATA_ELEMENT,*/ default:
			{
				input.skipBits(count);
				count = 0;
			}
		}
		return count;
	}

	private function decodeDynamicRangeInfo(input : BitStream, count : Int) : Int
	{
		if(dri==null) dri = new DynamicRangeInfo();

		var bandCount : Int = 1;

		//pce tag
		if (dri.pceTagPresent = input.readBool())
		{
			dri.pceInstanceTag = input.readBits(4);
			dri.tagReservedBits = input.readBits(4);
		}

		//excluded channels
		if (dri.excludedChannelsPresent = input.readBool())
		{
			count -= decodeExcludedChannels(input);
		}

		//bands
		if (dri.bandsPresent = input.readBool())
		{
			dri.bandsIncrement = input.readBits(4);
			dri.interpolationScheme = input.readBits(4);
			count -= 8;
			bandCount += dri.bandsIncrement;
			dri.bandTop = new Vector<Int>(bandCount);
			for (i in 0...bandCount)
			{
				dri.bandTop[i] = input.readBits(8);
				count -= 8;
			}
		}

		//prog ref level
		if (dri.progRefLevelPresent = input.readBool())
		{
			dri.progRefLevel = input.readBits(7);
			dri.progRefLevelReservedBits = input.readBits(1);
			count -= 8;
		}

		dri.dynRngSgn = new Vector<Bool>(bandCount);
		dri.dynRngCtl = new Vector<Int>(bandCount);
		for (i in 0...bandCount)
		{
			dri.dynRngSgn[i] = input.readBool();
			dri.dynRngCtl[i] = input.readBits(7);
			count -= 8;
		}
		return count;
	}

	private function decodeExcludedChannels(input : BitStream) : Int
	{
		var exclChs : Int = 0;

		do {
			for (i in 0...7)
			{
				dri.excludeMask[exclChs] = input.readBool();
				exclChs++;
			}
		}
		while(exclChs<57&&input.readBool());

		return IntDivision.intDiv(exclChs, 7)*8;
	}
	
}