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
import impl.error.HCR;
import impl.error.RVLC;
import impl.gain.GainControl;
import impl.huffman.HCB;
import impl.huffman.Huffman;
import impl.invquant.InvQuant;
import impl.noise.TNS;

class ICStream 
{
	private static var SF_DELTA : Int = 60;
	private var frameLength : Int;
	//always needed
	private var info : ICSInfo;
	var sectionData : SectionData;
	var data : Vector<Int>;
	private var scaleFactors : Vector<Vector<Int>>;
	private var globalGain : Int;
	private var pulseDataPresent : Bool;
	private var tnsDataPresent : Bool;
	private var gainControlPresent : Bool;
	//only allocated if needed
	private var tns : TNS;
	private var gainControl : GainControl;
	private var pulseOffset : Vector<Int>;
	private var pulseAmp : Vector<Int>;
	private var pulseCount : Int;
	private var pulseStartSWB : Int;
	//error resilience
	private var noiseUsed : Bool;
	private var reorderedSpectralDataLen : Int;
	private var longestCodewordLen : Int;
	private var rvlc : RVLC;
	private var huffman : Huffman;
	
	public function new(huff : Huffman, frameLength : Int)
	{
		this.frameLength = frameLength;
		info = new ICSInfo(frameLength);
		sectionData = new SectionData();
		data = new Vector<Int>(frameLength);
		huffman = huff;
	}

	/* ========= decoding ========== */
	public function decode(input : BitStream, commonWindow : Bool, conf : DecoderConfig)
	{
		if(conf.isScalefactorResilienceUsed()&&rvlc==null) rvlc = new RVLC();
		var er : Bool = conf.getProfile().isErrorResilientProfile();

		globalGain = input.readBits(8);

		if(!commonWindow) info.decode(input, conf, commonWindow);
		
		sectionData.decode(input, info, conf.isSectionDataResilienceUsed());
		if(conf.isScalefactorResilienceUsed()) rvlc.decode(input, this, scaleFactors);
		else decodeScaleFactors(input);
		
		pulseDataPresent = input.readBool();
		if (pulseDataPresent)
		{
			if(info.isEightShortFrame()) throw("pulse data not allowed for short frames");
			//LOGGER.log(Level.FINE, "PULSE");
			decodePulseData(input);
		}

		tnsDataPresent = input.readBool();
		if (tnsDataPresent && !er)
		{
			if(tns==null) tns = new TNS();
			tns.decode(input, info);
		}

		gainControlPresent = input.readBool();
		if (gainControlPresent)
		{
			if(gainControl==null) gainControl = new GainControl(frameLength);
			//LOGGER.log(Level.FINE, "GAIN");
			trace("GAIN");
			gainControl.decode(input, info.getWindowSequence());
		}
		
		//RVLC spectral data
		//if(conf.isScalefactorResilienceUsed()) rvlc.decodeScalefactors(this, in, scaleFactors);

		if (conf.isSpectralDataResilienceUsed())
		{
			var max : Int = (conf.getChannelConfiguration()==ChannelConfiguration.CHANNEL_CONFIG_STEREO) ? 6144 : 12288;
			reorderedSpectralDataLen = IntMath.max(input.readBits(14), max);
			longestCodewordLen = IntMath.max(input.readBits(6), 49);
			HCR.decodeReorderedSpectralData(huffman, this, input, data, conf.isSectionDataResilienceUsed());
		}
		else
		{			
			decodeSpectralData(input);
		}
	}

	private function decodePulseData(input : BitStream)
	{
		pulseCount = input.readBits(2)+1;
		pulseStartSWB = input.readBits(6);
		if(pulseStartSWB>=info.getSWBCount()) throw("pulse SWB out of range: "+pulseStartSWB+" > "+info.getSWBCount());

		pulseOffset = new Vector<Int>(pulseCount);
		pulseAmp = new Vector<Int>(pulseCount);

		pulseOffset[0] = info.getSWBOffsets()[pulseStartSWB];
		pulseOffset[0] += input.readBits(5);
		pulseAmp[0] = input.readBits(4);
		for (i in 1...pulseCount)
		{
			pulseOffset[i] = input.readBits(5)+pulseOffset[i-1];
			if(pulseOffset[i]>1023) throw("pulse offset out of range: "+pulseOffset[0]);
			pulseAmp[i] = input.readBits(4);
		}
	}

	public function decodeScaleFactors(input : BitStream)
	{
		noiseUsed = false;
		var maxSFB : Int = info.getMaxSFB();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var sfbCB : Vector<Vector<Int>> = sectionData.getSfbCB();
		//scaleFactors = new int[windowGroupCount][maxSFB];
		scaleFactors = VectorTools.newMatrixVectorI(windowGroupCount, maxSFB);

		var scaleFactor : Int = globalGain;
		var isPosition : Int = 0;
		var noiseEnergy : Int = globalGain-90-256;
		var noisePCM : Bool = true;
		for (g in 0...windowGroupCount)
		{
			for (sfb in 0...maxSFB)
			{
				switch(sfbCB[g][sfb])
				{
					case HCB.ZERO_HCB:
					{
						scaleFactors[g][sfb] = 0;
					}
					case HCB.INTENSITY_HCB, HCB.INTENSITY_HCB2:
					{
						isPosition += huffman.decodeScaleFactor(input)-60;
						scaleFactors[g][sfb] = isPosition;
					}
					case HCB.NOISE_HCB:
					{
						if(!noiseUsed) noiseUsed = true;
						if (noisePCM)
						{
							noisePCM = false;
							noiseEnergy += input.readBits(9);
						}
						else noiseEnergy += huffman.decodeScaleFactor(input)-ICStream.SF_DELTA;
						scaleFactors[g][sfb] = noiseEnergy;
					}
					default:
					{
						scaleFactor += huffman.decodeScaleFactor(input)-ICStream.SF_DELTA;
						scaleFactors[g][sfb] = scaleFactor;
					}
				}
			}
		}
	}

	private function decodeSpectralData(input : BitStream)
	{
		var numSec : Vector<Int> = sectionData.getNumSec();
		var sectCB : Vector<Vector<Int>> = sectionData.getSectCB();
		var sectSFBOffset : Vector<Vector<Int>> = info.getSectSFBOffsets();
		var sectStart : Vector<Vector<Int>> = sectionData.getSectStart();
		var sectEnd : Vector<Vector<Int>> = sectionData.getSectEnd();
		var shortFrameLen : Int = IntDivision.intDiv(data.length, 8);
		//int i, k, inc, hcb, p;
		var k : Int;
		var inc : Int;
		var hcb : Int;
		var p : Int;
		var start : Int;
		var end : Int;
		var startOff : Int;
		var endOff : Int;
		var wins : Int = 0;
		
		for (g in 0...info.getWindowGroupCount())
		{
			p = wins*shortFrameLen;

			for (i in 0...numSec[g])
			{
				hcb = sectCB[g][i];
				inc = (hcb>=HCB.FIRST_PAIR_HCB) ? 2 : 4;
				start = sectStart[g][i];
				end = sectEnd[g][i];
				startOff = sectSFBOffset[g][start];
				endOff = sectSFBOffset[g][end];
				
				switch(hcb)
				{
					case HCB.ZERO_HCB, HCB.NOISE_HCB, HCB.INTENSITY_HCB, HCB.INTENSITY_HCB2:
					{
						p += (endOff - startOff);
					}
					default:
					{
						k = startOff;						
						while (k < endOff)
						{
							huffman.decodeSpectralData(input, hcb, data, p);							
							p += inc;
							k += inc;
						}
					}
				}				
			}			
			wins += info.getWindowGroupLength(g);
		}
	}

	/* ========= processing ========= */
	/**
	 * Does inverse quantization and applies the scale factors on the decoded
	 * data. After this the noiseless decoding is finished and the decoded data
	 * is returned.
	 * @return the inverse quantized and scaled data
	 */
	public function getInvQuantData() : Vector<Float>
	{
		if (pulseDataPresent)
		{
			var k : Int = IntMath.min(info.getSWBOffsets()[pulseStartSWB], info.getSWBOffsetMax());
			for (i in 0...(pulseCount+1))
			{
				k += pulseOffset[i];
				if(k>=cast(data.length, Int)) throw("pulse offset out of range");

				if(data[k]>0) data[k] += pulseAmp[i];
				else data[k] -= pulseAmp[i];
			}
		}
		var d : Vector<Float> = new Vector<Float>(data.length);
		InvQuant.process(info, data, d, scaleFactors);
		return d;
	}
	
	public function getInfo() : ICSInfo
	{
		return info;
	}
	
	public function isTNSDataPresent() : Bool
	{
		return tnsDataPresent;
	}
	
	public function getTNS() : TNS
	{
		return tns;
	}
	
	public function getSectionData() : SectionData
	{
		return sectionData;
	}
	
	public function getGlobalGain() : Int
	{
		return globalGain;
	}
	
	public function getReorderedSpectralDataLength() : Int
	{
		return reorderedSpectralDataLen;
	}
	
	public function getLongestCodewordLength() : Int
	{
		return longestCodewordLen;
	}
	
	public function isGainControlPresent() : Bool
	{
		return gainControlPresent;
	}
	
	public function getGainControl() : GainControl
	{
		return gainControl;
	}
	
	public function getScaleFactors() : Vector<Vector<Int>>
	{
		return scaleFactors;
	}
	
}