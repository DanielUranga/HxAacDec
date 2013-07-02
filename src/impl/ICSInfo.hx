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
import impl.prediction.ICPrediction;
import impl.prediction.LTPrediction;

enum WindowSequence
{
	ONLY_LONG_SEQUENCE;
	LONG_START_SEQUENCE;
	EIGHT_SHORT_SEQUENCE;
	LONG_STOP_SEQUENCE;
}
 
class ICSInfo 
{
	
	public static var WINDOW_SHAPE_SINE : Int = 0;
	public static var WINDOW_SHAPE_KAISER : Int = 1;
	public static var PREVIOUS : Int = 0;
	public static var CURRENT : Int = 1;
	
	public static inline function forInt(i : Int) : WindowSequence
	{
		var w : WindowSequence;
		switch(i)
		{
			case 0:
				w = ONLY_LONG_SEQUENCE;
			case 1:
				w = LONG_START_SEQUENCE;
			case 2:
				w = EIGHT_SHORT_SEQUENCE;
			case 3:
				w = LONG_STOP_SEQUENCE;
			default:
				throw("unknown window sequence type");
		}
		return w;
	}
	
	private var frameLength : Int;
	private var shortFrameLen : Int;
	private var windowSequence : WindowSequence;
	private var windowShape : Vector<Int>;
	private var maxSFB : Int;
	//prediction
	private var predictionDataPresent : Bool;
	private var icPredict : ICPrediction;
	public var ltpData1Present : Bool;
	public var ltpData2Present : Bool;
	private var ltPredict1 : LTPrediction;
	private var ltPredict2 : LTPrediction;
	//windows/sfbs
	private var windowCount : Int;
	private var windowGroupCount : Int;
	private var windowGroupLength : Vector<Int>;
	private var swbCount : Int;
	private var swbOffsets : Vector<Int>;
	private var sectSFBOffsets : Vector<Vector<Int>>;
	
	public function new(frameLength : Int)
	{
		this.frameLength = frameLength;
		shortFrameLen = IntDivision.intDiv(frameLength, 8);
		windowShape = new Vector<Int>(2);
		windowSequence = WindowSequence.ONLY_LONG_SEQUENCE;
		windowGroupLength = new Vector<Int>(Constants.MAX_WINDOW_GROUP_COUNT);
		//sectSFBOffsets = new int[MAX_WINDOW_GROUP_COUNT][MAX_SWB_COUNT+1];
		sectSFBOffsets = VectorTools.newMatrixVectorI(Constants.MAX_WINDOW_GROUP_COUNT, Constants.MAX_SWB_COUNT+1);
		ltpData1Present = false;
		ltpData2Present = false;
	}

	/* ========== decoding ========== */
	public function decode(input : BitStream, conf : DecoderConfig, commonWindow : Bool)
	{
		var sf : SampleFrequency = conf.getSampleFrequency();
		if(sf==SampleFrequency.SAMPLE_FREQUENCY_NONE) throw("invalid sample frequency");

		input.skipBit(); //reserved
		windowSequence = ICSInfo.forInt(input.readBits(2));
		windowShape[PREVIOUS] = windowShape[CURRENT];
		windowShape[CURRENT] = input.readBit();

		var grouping : Int = 0;
		if (windowSequence == WindowSequence.EIGHT_SHORT_SEQUENCE)
		{
			maxSFB = input.readBits(4);
			grouping = input.readBits(7);
		}
		else
		{
			maxSFB = input.readBits(6);
			predictionDataPresent = input.readBool();
			if(predictionDataPresent) readPredictionData(input, conf.getProfile(), sf, commonWindow);
		}
		
		if(windowSequence==WindowSequence.EIGHT_SHORT_SEQUENCE) computeWindowGroupingInfoShort(sf, grouping);
		else computeWindowGroupingInfoLong(sf);
	}

	private function readPredictionData(input : BitStream, profile : Profile, sf : SampleFrequency, commonWindow : Bool)
	{
		switch(profile)
		{
			case x if (x==Profile.AAC_MAIN):
			{
				if(icPredict==null) icPredict = new ICPrediction();
				icPredict.decode(input, maxSFB, sf);
			}
			case x if (x==Profile.AAC_LTP):
			{
				if (ltpData1Present = input.readBool())
				{
					if(ltPredict1==null) ltPredict1 = new LTPrediction(frameLength);
					ltPredict1.decode(input, this, profile);
				}
				if (commonWindow)
				{
					if (ltpData2Present = input.readBool())
					{
						if(ltPredict2==null) ltPredict2 = new LTPrediction(frameLength);
						ltPredict2.decode(input, this, profile);
					}
				}
			}
			case x if (x==Profile.ER_AAC_LTP):
				if (!commonWindow)
				{
					if (ltpData1Present = input.readBool())
					{
						if(ltPredict1==null) ltPredict1 = new LTPrediction(frameLength);
						ltPredict1.decode(input, this, profile);
					}
				}
			default:
			{
				throw("unexpected profile for LTP: " + profile);
			}
		}
	}

	private function computeWindowGroupingInfoLong(sf : SampleFrequency)
	{
		windowCount = 1;
		windowGroupCount = 1;
		windowGroupLength[0] = 1;
		swbCount = ScaleFactorBands.SWB_LONG_WINDOW_COUNT[sf.getIndex()];
		swbOffsets = new Vector<Int>(swbCount+1);

		var offset : Int;
		for (i in 0...(swbCount + 1))
		{
			offset = ScaleFactorBands.SWB_OFFSET_LONG_WINDOW[sf.getIndex()][i];
			if (offset < 0) throw("invalid swb offset while decoding ICSInfo");
			sectSFBOffsets[0][i] = offset;
			swbOffsets[i] = offset;
		}
		if(sectSFBOffsets[0][swbCount]!=frameLength) throw("unexpected window length while decoding ICSInfo: "+sectSFBOffsets[0][swbCount]);
	}

	private function computeWindowGroupingInfoShort(sf : SampleFrequency, scaleFactorGrouping : Int)
	{
		windowCount = 8;
		windowGroupCount = 1;
		windowGroupLength[0] = 1;
		swbCount = ScaleFactorBands.SWB_SHORT_WINDOW_COUNT[sf.getIndex()];
		swbOffsets = new Vector<Int>(swbCount+1);

		for (i in 0...(swbCount + 1))
		{
			swbOffsets[i] = ScaleFactorBands.SWB_OFFSET_SHORT_WINDOW[sf.getIndex()][i];
		}

		var bit : Int = 1<<7;
		for (i in 0...(windowCount - 1))
		{
			bit >>= 1;
			if ((scaleFactorGrouping & bit) == 0)
			{
				windowGroupCount++;
				windowGroupLength[windowGroupCount-1] = 1;
			}
			else windowGroupLength[windowGroupCount-1]++;
		}
		var offset : Int;
		var sectSFB : Int;
		var width : Int;
		for (g in 0...windowGroupCount)
		{
			sectSFB = 0;
			offset = 0;

			for (i in 0...swbCount)
			{
				if(i+1==swbCount) width = shortFrameLen-ScaleFactorBands.SWB_OFFSET_SHORT_WINDOW[sf.getIndex()][i];
				else width = ScaleFactorBands.SWB_OFFSET_SHORT_WINDOW[sf.getIndex()][i + 1] - ScaleFactorBands.SWB_OFFSET_SHORT_WINDOW[sf.getIndex()][i];
				width *= windowGroupLength[g];
				sectSFBOffsets[g][sectSFB++] = offset;
				offset += width;
			}
			sectSFBOffsets[g][sectSFB] = offset;
		}
	}
	
	public function isEightShortFrame() : Bool
	{
		return windowSequence == WindowSequence.EIGHT_SHORT_SEQUENCE;
	}
	
	public function getMaxSFB() : Int
	{
		return maxSFB;
	}
	
	public function getSWBOffsets() : Vector<Int>
	{
		return swbOffsets;
	}
	
	public function getWindowGroupCount() : Int
	{
		return windowGroupCount;
	}
	
	public function getWindowCount() : Int
	{
		return windowCount;
	}
	
	public function getWindowSequence() : WindowSequence
	{
		return windowSequence;
	}
	
	public function getWindowShape(index : Int) : Int
	{
		return windowShape[index];
	}
	
	public function getSWBOffsetMax() : Int
	{
		return swbOffsets[swbCount];
	}
	
	public function getSWBCount() : Int
	{
		return swbCount;
	}
	
	public function getWindowGroupLength(g : Int) : Int
	{
		return windowGroupLength[g];
	}
	
	public function isLTPrediction1Present() : Bool
	{
		return ltpData1Present;
	}
	
	public function isLTPrediction2Present() : Bool
	{
		return ltpData2Present;
	}
	
	public function getLTPrediction1() : LTPrediction
	{
		return ltPredict1;
	}
	
	public function getLTPrediction2() : LTPrediction
	{
		return ltPredict2;
	}
	
	public function getSectSFBOffsets() : Vector<Vector<Int>>
	{
		return sectSFBOffsets;
	}
	
	public function isICPredictionPresent() : Bool
	{
		return predictionDataPresent;
	}
	
	public function getICPrediction() : ICPrediction
	{
		return icPredict;
	}
	
	public function unsetPredictionSFB(sfb : Int)
	{
		if(predictionDataPresent) icPredict.setPredictionUnused(sfb);
		if(ltpData1Present) ltPredict1.setPredictionUnused(sfb);
		if(ltpData2Present) ltPredict2.setPredictionUnused(sfb);
	}
	
	public function setData(info : ICSInfo)
	{
		windowSequence = info.windowSequence;
		windowShape[PREVIOUS] = info.windowShape[PREVIOUS];
		windowShape[CURRENT] = info.windowShape[CURRENT];
		maxSFB = info.maxSFB;
		predictionDataPresent = info.predictionDataPresent;
		if(predictionDataPresent) icPredict = info.icPredict;
		ltpData1Present = info.ltpData1Present;
		if (ltpData1Present)
		{
			ltPredict1.copy(info.ltPredict1);
			ltPredict2.copy(info.ltPredict2);
		}
		windowCount = info.windowCount;
		windowGroupCount = info.windowGroupCount;
		//windowGroupLength = Arrays.copyOf(info.windowGroupLength, info.windowGroupLength.length);
		windowGroupLength = VectorTools.copyOfI(info.windowGroupLength, info.windowGroupLength.length);
		swbCount = info.swbCount;
		//swbOffsets = Arrays.copyOf(info.swbOffsets, info.swbOffsets.length);
		swbOffsets = VectorTools.copyOfI(info.swbOffsets, info.swbOffsets.length);
		sectSFBOffsets = new Vector<Vector<Int>>(info.sectSFBOffsets.length);
		for (i in 0...info.sectSFBOffsets.length)
		{
			//sectSFBOffsets[i] = Arrays.copyOf(info.sectSFBOffsets[i], info.sectSFBOffsets[i].length);
			sectSFBOffsets[i] = VectorTools.copyOfI(info.sectSFBOffsets[i], info.sectSFBOffsets[i].length);
		}
	}
	
}