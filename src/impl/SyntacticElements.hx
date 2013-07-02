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
import haxe.io.BytesData;
import impl.filterbank.FilterBank;
import impl.huffman.Huffman;
import impl.noise.PNS;
import impl.prediction.LTPrediction;
import impl.sbr.SBR;
import impl.stereo.IS;
import impl.stereo.MS;

class SyntacticElements 
{

	//global properties
	private var config : DecoderConfig;
	private var sbrPresent : Bool;
	private var psPresent : Bool;
	//elements
	private var pce : PCE;
	private var elements : Vector<Element>; //SCE, LFE and CPE
	private var cces : Vector<CCE>;
	private var dses : Vector<DSE>;
	private var fils : Vector<FIL>;
	private var curElem : Int;
	private var curCCE : Int;
	private var curDSE : Int;
	private var curFIL : Int;
	private var data : Vector<Vector<Float>>;
	private var huffman : Huffman;

	public function new(config : DecoderConfig)
	{
		this.config = config;
		this.sbrPresent = config.isSBRPresent();
		psPresent = false;

		pce = new PCE();
		elements = new Vector<Element>(4*Constants.MAX_ELEMENTS, true);
		cces = new Vector<CCE>(Constants.MAX_ELEMENTS, true);
		dses = new Vector<DSE>(Constants.MAX_ELEMENTS, true);
		fils = new Vector<FIL>(Constants.MAX_ELEMENTS, true);

		curElem = 0;
		curCCE = 0;
		curDSE = 0;
		curFIL = 0;
		
		huffman = new Huffman();
	}

	public function startNewFrame()
	{
		curElem = 0;
		curCCE = 0;
		curDSE = 0;
		curFIL = 0;
	}

	public function decode(input : BitStream)
	{
		var type : Int;
		var prev : Element = null;
		var content : Bool = true;
		if (!config.getProfile().isErrorResilientProfile())
		{
			while (content && (type = input.readBits(3)) != -1)
			{
				switch(type)
				{
					case Constants.ELEMENT_SCE, Constants.ELEMENT_LFE:
					{
						//LOGGER.finest("SCE");
						//trace("SCE");
						prev = decodeSCE_LFE(input);
					}
					case Constants.ELEMENT_CPE:
					{
						//LOGGER.finest("CPE")
						//trace("CPE");
						prev = decodeCPE(input);
					}
					case Constants.ELEMENT_CCE:
					{
						//LOGGER.finest("CCE");
						//trace("CCE");
						decodeCCE(input);
						prev = null;
					}
					case Constants.ELEMENT_DSE:
					{
						//LOGGER.finest("DSE");
						//trace("DSE");
						decodeDSE(input);
						prev = null;
					}
					case Constants.ELEMENT_PCE:
					{
						//LOGGER.finest("PCE");
						//trace("PCE");
						decodePCE(input);
						prev = null;
					}
					case Constants.ELEMENT_FIL:
					{
						//LOGGER.finest("FIL");
						//trace("FIL");
						decodeFIL(input, prev);
						prev = null;
					}
					case Constants.ELEMENT_END:
					{
						//LOGGER.finest("END");
						//trace("END");
						content = false;
						prev = null;
					}
				}
			}
		}
		else
		{
			//error resilient raw data block
			switch(config.getChannelConfiguration())
			{
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_MONO):
				{
					decodeSCE_LFE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_STEREO):
				{
					decodeCPE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_STEREO_PLUS_CENTER):
				{
					decodeSCE_LFE(input);
					decodeCPE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_STEREO_PLUS_CENTER_PLUS_REAR_MONO):
				{
					decodeSCE_LFE(input);
					decodeCPE(input);
					decodeSCE_LFE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_FIVE):
				{
					decodeSCE_LFE(input);
					decodeCPE(input);
					decodeCPE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_FIVE_PLUS_ONE):
				{
					decodeSCE_LFE(input);
					decodeCPE(input);
					decodeCPE(input);
					decodeSCE_LFE(input);
				}
				case x if (x==ChannelConfiguration.CHANNEL_CONFIG_SEVEN_PLUS_ONE):
				{
					decodeSCE_LFE(input);
					decodeCPE(input);
					decodeCPE(input);
					decodeCPE(input);
					decodeSCE_LFE(input);
				}
				default:
					throw("unsupported channel configuration for error resilience: "+config.getChannelConfiguration());
			}
		}
		input.byteAlign();
	}

	private function decodeSCE_LFE(input : BitStream) : Element
	{
		if (elements[curElem] == null) elements[curElem] = new SCE_LFE(huffman, config.getFrameLength());
		cast(elements[curElem], SCE_LFE).decode(input, config);
		curElem++;
		return elements[curElem-1];
	}

	private function decodeCPE(input : BitStream) : Element
	{
		if(elements[curElem]==null) elements[curElem] = new CPE(huffman, config.getFrameLength());
		cast(elements[curElem], CPE).decode(input, config);
		curElem++;
		return elements[curElem-1];
	}

	private function decodeCCE(input : BitStream)
	{
		if(curCCE==Constants.MAX_ELEMENTS) throw("too much CCE elements");
		if(cces[curCCE]==null) cces[curCCE] = new CCE(huffman, config.getFrameLength());
		cces[curCCE].decode(input, config);
		curCCE++;
	}

	private function decodeDSE(input : BitStream)
	{
		if(curDSE==Constants.MAX_ELEMENTS) throw("too much CCE elements");
		if(dses[curDSE]==null) dses[curDSE] = new DSE();
		dses[curDSE].decode(input);
		curDSE++;
	}

	private function decodePCE(input : BitStream)
	{
		pce.decode(input);
		config.setProfile(pce.getProfile());
		config.setSampleFrequency(pce.getSampleFrequency());
		config.setChannelConfiguration(ChannelConfiguration.forInt(pce.getChannelCount()));
	}

	private function decodeFIL(input : BitStream, prev : Element)
	{
		if(curFIL==Constants.MAX_ELEMENTS) throw("too much FIL elements");
		if(fils[curFIL]==null) fils[curFIL] = new FIL(config.isSBRDownSampled());
		fils[curFIL].decode(input, prev, config.getSampleFrequency());
		curFIL++;

		if (!sbrPresent && prev != null && prev.isSBRPresent())
		{
			sbrPresent = true;
			if(!psPresent&&prev.getSBR().isPSUsed()) psPresent = true;
		}
	}

	public function process(filterBank : FilterBank)
	{
		var profile : Profile = config.getProfile();
		var sf : SampleFrequency = config.getSampleFrequency();
		//final ChannelConfiguration channels = config.getChannelConfiguration();
		
		var chs : Int = config.getChannelConfiguration().getChannelCount();
		if(chs==1&&psPresent) chs++;
		var mult : Int = sbrPresent ? 2 : 1;
		//only reallocate if needed
		if (data == null || chs != cast(data.length, Int) || (mult * config.getFrameLength()) != Std.int(data[0].length))
			//data = new float[chs][mult*config.getFrameLength()];
			data = VectorTools.newMatrixVectorF(chs+1, mult*config.getFrameLength());
		var channel : Int = 0;
		var e : Element;
		var scelfe : SCE_LFE;
		var cpe : CPE;
		for (i in 0...chs)
		{
			e = elements[i];
			if(e==null) continue;
			if (Std.is(e, SCE_LFE))
			{
				scelfe = cast(e, SCE_LFE);
				channel += processSingle(scelfe, filterBank, channel, profile, sf);
			}
			else if (Std.is(e, CPE))
			{				
				cpe = cast(e, CPE);
				processPair(cpe, filterBank, channel, profile, sf);
				channel += 2;
			}
			else if (Std.is(e, CCE))
			{				
				//applies invquant and save the result in the CCE
				cast(e, CCE).process();
			}
		}
	}

	private function processSingle(scelfe : SCE_LFE, filterBank : FilterBank, channel : Int, profile : Profile, sf : SampleFrequency) : Int
	{
		var ics : ICStream = scelfe.getICStream();
		var info : ICSInfo = ics.getInfo();
		var ltp : LTPrediction = info.getLTPrediction1();
		var elementID : Int = scelfe.getElementInstanceTag();
		
		//inverse quantization
		var iqData : Vector<Float> = ics.getInvQuantData();

		//PNS
		PNS.processSingle(ics, iqData);

		//prediction
		if(profile==Profile.AAC_MAIN&&info.isICPredictionPresent()) info.getICPrediction().process(ics, iqData, sf);
		if(LTPrediction.isLTPProfile(profile)&&info.isLTPrediction1Present()) ltp.process(ics, iqData, filterBank, sf);

		//dependent coupling
		processDependentCoupling(false, elementID, CCE.BEFORE_TNS, iqData, null);
		
		//TNS
		if(ics.isTNSDataPresent()) ics.getTNS().process(ics, iqData, sf, false);

		//dependent coupling
		processDependentCoupling(false, elementID, CCE.AFTER_TNS, iqData, null);
		
		//filterbank
		filterBank.process(info.getWindowSequence(), info.getWindowShape(ICSInfo.CURRENT), info.getWindowShape(ICSInfo.PREVIOUS), iqData, data[channel], channel);

		if(LTPrediction.isLTPProfile(profile)) ltp.updateState(data[channel], filterBank.getOverlap(channel), profile);

		//dependent coupling
		processIndependentCoupling(false, elementID, data[channel], null);

		//gain control
		if(ics.isGainControlPresent()) ics.getGainControl().process(iqData, info.getWindowShape(ICSInfo.CURRENT), info.getWindowShape(ICSInfo.PREVIOUS), info.getWindowSequence());
		
		//SBR
		var chs : Int = 1;
		if (sbrPresent)
		{
			if (cast(data[channel].length, Int) == config.getFrameLength()) //LOGGER.log(Level.WARNING, "SBR data present, but buffer has normal size!");
				trace("SBR data present, but buffer has normal size!");
			var sbr : SBR = scelfe.getSBR();
			if (sbr.isPSUsed())
			{
				chs = 2;
				scelfe.getSBR().processSingleFramePS(data[channel], data[channel + 1], false);
				/*
				try {
					scelfe.getSBR().processSingleFramePS(data[channel], data[channel + 1], false);
				} catch ( e : Dynamic )
				{
					trace("ERROR: data.length=" + data.length + " channel=" + channel);
				}
				*/
			}
			else
			{
				scelfe.getSBR().processSingleFrame(data[channel], false);
			}
		}
		return chs;
	}

	private function processPair(cpe : CPE, filterBank : FilterBank, channel : Int, profile : Profile, sf : SampleFrequency)
	{
		var ics1 : ICStream = cpe.getLeftChannel();
		var ics2 : ICStream = cpe.getRightChannel();
		var info1 : ICSInfo = ics1.getInfo();
		var info2 : ICSInfo = ics2.getInfo();
		var ltp1 : LTPrediction = info1.getLTPrediction1();
		var ltp2 : LTPrediction = cpe.isCommonWindow() ? info1.getLTPrediction2() : info2.getLTPrediction1();
		var elementID : Int = cpe.getElementInstanceTag();

		//inverse quantization
		var iqData1 : Vector<Float> = ics1.getInvQuantData();
		var iqData2 : Vector<Float> = ics2.getInvQuantData();

		//PNS
		if(cpe.isMSMaskPresent()) PNS.processPair(cpe, iqData1, iqData2);
		else {
			PNS.processSingle(ics1, iqData1);
			PNS.processSingle(ics2, iqData2);
		}

		//MS
		if(cpe.isCommonWindow()&&cpe.isMSMaskPresent()) MS.process(cpe, iqData1, iqData2);
		//main prediction
		if (profile==Profile.AAC_MAIN)
		{
			if(info1.isICPredictionPresent()) info1.getICPrediction().process(ics1, iqData1, sf);
			if(info2.isICPredictionPresent()) info2.getICPrediction().process(ics2, iqData2, sf);
		}
		//IS
		IS.process(cpe, iqData1, iqData2);

		//LTP
		if (LTPrediction.isLTPProfile(profile))
		{
			if(info1.isLTPrediction1Present()) ltp1.process(ics1, iqData1, filterBank, sf);
			if(cpe.isCommonWindow()&&info1.isLTPrediction2Present()) ltp2.process(ics2, iqData2, filterBank, sf);
			else if(info2.isLTPrediction1Present()) ltp2.process(ics2, iqData2, filterBank, sf);
		}

		//dependent coupling
		processDependentCoupling(true, elementID, CCE.BEFORE_TNS, iqData1, iqData2);

		//TNS
		if(ics1.isTNSDataPresent()) ics1.getTNS().process(ics1, iqData1, sf, false);
		if(ics2.isTNSDataPresent()) ics2.getTNS().process(ics2, iqData2, sf, false);

		//dependent coupling
		processDependentCoupling(true, elementID, CCE.AFTER_TNS, iqData1, iqData2);

		//filterbank
		filterBank.process(info1.getWindowSequence(), info1.getWindowShape(ICSInfo.CURRENT), info1.getWindowShape(ICSInfo.PREVIOUS), iqData1, data[channel], channel);
		filterBank.process(info2.getWindowSequence(), info2.getWindowShape(ICSInfo.CURRENT), info2.getWindowShape(ICSInfo.PREVIOUS), iqData2, data[channel+1], channel+1);

		if (LTPrediction.isLTPProfile(profile))
		{
			ltp1.updateState(data[channel], filterBank.getOverlap(channel), profile);
			ltp2.updateState(data[channel+1], filterBank.getOverlap(channel+1), profile);
		}

		//independent coupling
		processIndependentCoupling(true, elementID, data[channel], data[channel+1]);

		//gain control
		if(ics1.isGainControlPresent()) ics1.getGainControl().process(iqData1, info1.getWindowShape(ICSInfo.CURRENT), info1.getWindowShape(ICSInfo.PREVIOUS), info1.getWindowSequence());
		if(ics2.isGainControlPresent()) ics2.getGainControl().process(iqData2, info2.getWindowShape(ICSInfo.CURRENT), info2.getWindowShape(ICSInfo.PREVIOUS), info2.getWindowSequence());

		//SBR
		if (sbrPresent)
		{
			if (cast(data[channel].length, Int) == config.getFrameLength()) //LOGGER.log(Level.WARNING, "SBR data present, but buffer has normal size!");
				trace("SBR data present, but buffer has normal size!");
			cpe.getSBR().processCoupleFrame(data[channel], data[channel+1], false);
		}
	}

	private function processIndependentCoupling(channelPair : Bool, elementID : Int, data1 : Vector<Float>, data2 : Vector<Float>)
	{
		var index : Int;
		var c : Int;
		var chSelect : Int;
		for (i in 0...cces.length)
		{
			var cce : CCE = cces[i];
			index = 0;
			if (cce != null && cce.getCouplingPoint() == CCE.AFTER_IMDCT)
			{
				for (c in 0...(cce.getCoupledCount()+1))
				{
					chSelect = cce.getCHSelect(c);
					if (cce.isChannelPair(c) == channelPair && cce.getIDSelect(c) == elementID)
					{
						if (chSelect != 1)
						{
							cce.applyIndependentCoupling(index, data1);
							if(chSelect!=0) index++;
						}
						if (chSelect != 2)
						{
							cce.applyIndependentCoupling(index, data2);
							index++;
						}
					}
					else index += 1+((chSelect==3) ? 1 : 0);
				}
			}
		}
	}

	private function processDependentCoupling(channelPair : Bool, elementID : Int, couplingPoint : Int, data1 : Vector<Float>, data2 : Vector<Float>)
	{
		var index : Int;
		var c : Int;
		var chSelect : Int;
		for (i in 0...cces.length)
		{
			var cce : CCE = cces[i];
			index = 0;
			if (cce != null && cce.getCouplingPoint() == couplingPoint)
			{
				for (c in 0...(cce.getCoupledCount()+1))
				{
					chSelect = cce.getCHSelect(c);
					if (cce.isChannelPair(c) == channelPair && cce.getIDSelect(c) == elementID)
					{
						if (chSelect != 1)
						{
							cce.applyDependentCoupling(index, data1);
							if(chSelect!=0) index++;
						}
						if (chSelect != 2)
						{
							cce.applyDependentCoupling(index, data2);
							index++;
						}
					}
					else index += 1+((chSelect==3) ? 1 : 0);
				}
			}
		}
	}

	public function sendToOutput(buffer : SampleBuffer)
	{
		var chs : Int = data.length;
		var length : Int = (sbrPresent ? 2 : 1)*config.getFrameLength();
		var freq : Int = config.getSampleFrequency().getFrequency();
		if(sbrPresent) freq *= 2;
		buffer.setFormat(freq, chs, 16);

		var b : BytesData = buffer.getData();
		/*
		if (b.length != chs * length * 2)
			//b = new byte[chs*length*2];
			b = new BytesData();
		*/
		
		var cur : Vector<Float>;
		var off : Int;
		var s : Int;
		for (i in 0...chs)
		{
			cur = data[i];
			for (j in 0...length)
			{
				s = IntMath.max(IntMath.min(Math.round(cur[j]), 32767), -32768);
				off = (j*chs+i)*2;
				b[off] = (s >> 8) & Constants.BYTE_MASK;
				b[off + 1] = s & Constants.BYTE_MASK;
			}
		}

		b.position = 0;
		buffer.setData(b);
	}
	
}