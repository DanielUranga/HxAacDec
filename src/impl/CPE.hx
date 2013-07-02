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
import impl.huffman.Huffman;
import impl.stereo.MSMask;

class CPE extends Element
{

	private var msMask : MSMask;
	private var msUsed : Vector<Vector<Bool>>;
	private var commonWindow : Bool;
	var icsL : ICStream;
	var icsR : ICStream;

	public function new(huff : Huffman, frameLength : Int)
	{
		//super();
		//msUsed = new boolean[MAX_WINDOW_GROUP_COUNT][MAX_SWB_COUNT+1];
		msUsed = VectorTools.newMatrixVectorB(Constants.MAX_WINDOW_GROUP_COUNT, Constants.MAX_SWB_COUNT+1);
		icsL = new ICStream(huff, frameLength);
		icsR = new ICStream(huff, frameLength);
	}

	public function decode(input : BitStream, conf : DecoderConfig)
	{
		var profile : Profile = conf.getProfile();
		var sf : SampleFrequency = conf.getSampleFrequency();
		if(sf==SampleFrequency.SAMPLE_FREQUENCY_NONE) throw("invalid sample frequency");

		readElementInstanceTag(input);

		commonWindow = input.readBool();
		var info : ICSInfo = icsL.getInfo();
		if (commonWindow)
		{
			info.decode(input, conf, commonWindow);
			icsR.getInfo().setData(info);

			msMask = MSMask.forInt(input.readBits(2));
			if(msMask==MSMask.TYPE_RESERVED) throw("reserved MS mask type used");
			else if (msMask==MSMask.TYPE_USED)
			{
				var maxSFB : Int = info.getMaxSFB();
				var windowGroupCount : Int = info.getWindowGroupCount();

				for (g in 0...windowGroupCount)
				{
					for (sfb in 0...maxSFB)
					{
						msUsed[g][sfb] = input.readBool();
					}
				}
			}
		}
		else msMask = MSMask.TYPE_ALL_0;

		if (profile.isErrorResilientProfile() && (info.isLTPrediction1Present()))
		{
			if(info.ltpData2Present = input.readBool()) info.getLTPrediction2().decode(input, info, profile);
		}

		icsL.decode(input, commonWindow, conf);
		icsR.decode(input, commonWindow, conf);
	}

	public function getLeftChannel() : ICStream
	{
		return icsL;
	}

	public function getRightChannel() : ICStream
	{
		return icsR;
	}

	public function getMSMask() : MSMask
	{
		return msMask;
	}

	public function isMSUsed(g : Int, sfb : Int) : Bool
	{
		return msUsed[g][sfb];
	}

	public function isMSMaskPresent() : Bool
	{
		return !(msMask==MSMask.TYPE_ALL_0);
	}

	public function isCommonWindow() : Bool
	{
		return commonWindow;
	}
	
}