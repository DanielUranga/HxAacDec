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

/*static*/ class TaggedElement
{

	private var isCPE : Bool;
	private var tag : Int;

	public function new(isCPE : Bool, tag : Int)
	{
		this.isCPE = isCPE;
		this.tag = tag;
	}

	public function isIsCPE() : Bool
	{
		return isCPE;
	}

	public function getTag() : Int
	{
		return tag;
	}
}

/*static*/ class _CCE
{

	private var isIndSW : Bool;
	private var tag : Int;

	public function new(isIndSW : Bool, tag : Int)
	{
		this.isIndSW = isIndSW;
		this.tag = tag;
	}

	public function isIsIndSW() : Bool
	{
		return isIndSW;
	}

	public function getTag() : Int
	{
		return tag;
	}
}
 
class PCE extends Element
{

	private static var MAX_FRONT_CHANNEL_ELEMENTS : Int = 16;
	private static var MAX_SIDE_CHANNEL_ELEMENTS : Int = 16;
	private static var MAX_BACK_CHANNEL_ELEMENTS : Int = 16;
	private static var MAX_LFE_CHANNEL_ELEMENTS : Int = 4;
	private static var MAX_ASSOC_DATA_ELEMENTS : Int = 8;
	private static var MAX_VALID_CC_ELEMENTS : Int = 16;

	private var profile : Profile;
	private var sampleFrequency : SampleFrequency;
	private var frontChannelElementsCount : Int;
	private var sideChannelElementsCount : Int;
	private var backChannelElementsCount : Int;
	private var lfeChannelElementsCount : Int;
	private var assocDataElementsCount : Int;
	private var validCCElementsCount : Int;
	private var monoMixdown : Bool;
	private var stereoMixdown : Bool;
	private var matrixMixdownIDXPresent : Bool;
	private var monoMixdownElementNumber : Int;
	private var stereoMixdownElementNumber : Int;
	private var matrixMixdownIDX : Int;
	private var pseudoSurround : Bool;
	private var frontElements : Vector<TaggedElement>;
	private var sideElements : Vector<TaggedElement>;
	private var backElements : Vector<TaggedElement>;
	private var lfeElementTags : Vector<Int>;
	private var assocDataElementTags : Vector<Int>;
	private var ccElements : Vector<_CCE>;
	private var commentFieldData : Vector<Int>;

	public function new()
	{
		//super();
		frontElements = new Vector<TaggedElement>(MAX_FRONT_CHANNEL_ELEMENTS);
		sideElements = new Vector<TaggedElement>(MAX_SIDE_CHANNEL_ELEMENTS);
		backElements = new Vector<TaggedElement>(MAX_BACK_CHANNEL_ELEMENTS);
		lfeElementTags = new Vector<Int>(MAX_LFE_CHANNEL_ELEMENTS);
		assocDataElementTags = new Vector<Int>(MAX_ASSOC_DATA_ELEMENTS);
		ccElements = new Vector<_CCE>(MAX_VALID_CC_ELEMENTS);
		sampleFrequency = SampleFrequency.SAMPLE_FREQUENCY_NONE;
	}

	public function decode(input)
	{
		readElementInstanceTag(input);
		
		profile = Profile.forInt(input.readBits(2));

		sampleFrequency = SampleFrequency.forInt(input.readBits(4));

		frontChannelElementsCount = input.readBits(4);
		sideChannelElementsCount = input.readBits(4);
		backChannelElementsCount = input.readBits(4);
		lfeChannelElementsCount = input.readBits(2);
		assocDataElementsCount = input.readBits(3);
		validCCElementsCount = input.readBits(4);

		monoMixdown = input.readBool();
		if (monoMixdown)
		{
			monoMixdownElementNumber = input.readBits(4);
		}
		stereoMixdown = input.readBool();
		if (stereoMixdown)
		{
			stereoMixdownElementNumber = input.readBits(4);
		}
		matrixMixdownIDXPresent = input.readBool();
		if (matrixMixdownIDXPresent)
		{
			matrixMixdownIDX = input.readBits(2);
			pseudoSurround = input.readBool();
		}

		readTaggedElementArray(frontElements, input, frontChannelElementsCount);
		readTaggedElementArray(sideElements, input, sideChannelElementsCount);
		readTaggedElementArray(backElements, input, backChannelElementsCount);

		for (i in 0...lfeChannelElementsCount)
		{
			lfeElementTags[i] = input.readBits(4);
		}

		for (i in 0...assocDataElementsCount)
		{
			assocDataElementTags[i] = input.readBits(4);
		}

		for (i in 0...validCCElementsCount)
		{
			ccElements[i] = new _CCE(input.readBool(), input.readBits(4));
		}

		input.byteAlign();

		var commentFieldBytes : Int = input.readBits(8);
		commentFieldData = new Vector<Int>(commentFieldBytes);
		for (i in 0...commentFieldBytes)
		{
			commentFieldData[i] = input.readBits(8);
		}
	}

	private function readTaggedElementArray(tag_elt : Vector<TaggedElement>, input : BitStream, num : Int)
	{
		for (i in 0...num)
		{
			tag_elt[i] = new TaggedElement(input.readBool(), input.readBits(4));
		}
	}

	public function getProfile() : Profile
	{
		return profile;
	}

	public function getSampleFrequency() : SampleFrequency
	{
		return sampleFrequency;
	}

	public function getChannelCount() : Int
	{
		return frontChannelElementsCount+sideChannelElementsCount+backChannelElementsCount
				+lfeChannelElementsCount+assocDataElementsCount;
	}
	
}