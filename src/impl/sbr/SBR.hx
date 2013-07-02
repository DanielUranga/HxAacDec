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
import impl.BitStream;
import impl.Constants;
import impl.IntDivision;
import impl.IntMath;
import impl.ps.PS;
import impl.VectorTools;

class SBR 
{
	
	private var cd : Vector<ChannelData>;
	public var sampleRate : Int;
	public var reset : Bool;
	//header
	private var headerCount : Int;
	public var ampRes : Bool;
	private var startFrequency : Int;
	private var startFrequencyPrev : Int;
	private var stopFrequency : Int;
	private var stopFrequencyPrev : Int;
	private var xOverBand : Int;
	private var xOverBandPrev : Int;
	private var frequencyScale : Int;
	private var frequencyScalePrev : Int;
	private var alterScale : Bool;
	private var alterScalePrev : Bool;
	private var noiseBands : Int;
	private var noiseBandsPrev : Int;
	public var limiterBands : Int;
	public var limiterGains : Int;
	public var interpolFrequency : Bool;
	public var smoothingMode : Bool;
	//read
	public var coupling : Bool;
	public var extensionID : Int;
	public var extensionData : Int;
	//calculated
	public var k0 : Int; //first band (=f_master[0])
	public var kx : Int;
	public var kxPrev : Int;
	public var mft : Vector<Int>; //master frequency table
	public var ftRes : Vector<Vector<Int>>; //0=ftHigh and 1=ftLow
	public var ftNoise : Vector<Int>; //frequency border table for noise floors
	public var ftLim : Vector<Vector<Int>>; //limiter frequency table
	public var N_master : Int; //length of MFT
	public var N_high : Int;
	public var N_low : Int;
	public var N_Q : Int;
	public var M : Int;
	public var Mprev : Int;
	public var N_L : Vector<Int>;
	public var n : Vector<Int>; //number of frequency bands for low (0) and high (1) frequency
	//patches
	public var tableMapKToG : Vector<Int>;
	public var patches : Int; //number of patches
	public var patchNoSubbands : Vector<Int>;
	public var patchStartSubband : Vector<Int>;
	//filterbank
	private var filterBank : Filterbank;
	private var qmfa : Vector<QMFAnalysis>;
	private var qmfs : Vector<QMFSynthesis>;
	private var hfAdj : HFAdjustment;
	private var hfGen : HFGeneration;
	//processing buffers
	private var buffer : Vector<Vector<Vector<Float>>>;
	private var bufLeftPS : Vector<Vector<Vector<Float>>>;
	private var bufRightPS : Vector<Vector<Vector<Float>>>;
	//PS extension data
	private var ps : PS;
	private var psUsed : Bool;
	private var psExtensionRead : Bool;
	
	public function new(sf : SampleFrequency, downSampled : Bool)
	{
		//global
		sampleRate = 2*sf.getFrequency();

		cd = new Vector<ChannelData>(2);
		cd[0] = new ChannelData();
		cd[1] = new ChannelData();
		filterBank = new Filterbank();
		qmfa = new Vector<QMFAnalysis>(2);
		qmfa[0] = new QMFAnalysis(filterBank, 32);
		qmfs = new Vector<QMFSynthesis>(2);
		qmfs[0] = new QMFSynthesis(filterBank, downSampled ? 32 : 64);
		hfAdj = new HFAdjustment(this);
		hfGen = new HFGeneration(this);

		patchNoSubbands = new Vector<Int>(64);
		patchStartSubband = new Vector<Int>(64);
		N_L = new Vector<Int>(4);
		n = new Vector<Int>(2);
		tableMapKToG = new Vector<Int>(64);
		mft = new Vector<Int>(64);
		//ftRes = new int[2][64];
		ftRes = VectorTools.newMatrixVectorI(2, 64);
		ftNoise = new Vector<Int>(64);
		//ftLim = new int[4][64];
		ftLim = VectorTools.newMatrixVectorI(4, 64);

		//header defaults
		frequencyScale = 2;
		alterScale = true;
		noiseBands = 2;
		limiterBands = 2;
		limiterGains = 2;
		interpolFrequency = true;
		smoothingMode = true;
		startFrequency = 5;
		ampRes = true;

		Mprev = 0;

		startFrequencyPrev = -1; //forces reset
	}

	/* ================== decoding ================== */
	public function decode(input : BitStream, count : Int, stereo : Bool, crc : Bool)
	{
		var pos : Int = input.getPosition();

		if (crc)
		{
			//LOGGER.info("SBR CRC bits present");
			trace("SBR CRc bits present");
			input.skipBits(10); //TODO: implement crc check
		}

		if (input.readBool()) decodeHeader(input);	

		reset_();

		//first frame should have a header
		if(headerCount>0) decodeData(input, stereo);
		else
		{
			//LOGGER.warning("no SBR header found");
			trace("no SBR header found");
		}

		var len : Int = input.getPosition()-pos;
		var bitsLeft : Int = count-len;
		if (bitsLeft >= 8)
		{
			//LOGGER.log(Level.WARNING, "SBR: bits left: {0}", bitsLeft);
			trace("SBR: bits left: " + bitsLeft);
		}
		else if(bitsLeft<0) throw("SBR data overread");

		input.skipBits(bitsLeft);
	}

	private function decodeHeader(input : BitStream)
	{
		headerCount++;

		ampRes = input.readBool();
		startFrequency = input.readBits(4);
		stopFrequency = input.readBits(4);
		xOverBand = input.readBits(3);
		input.skipBits(2); //reserved

		var extraHeader1 : Bool = input.readBool();
		var extraHeader2 : Bool = input.readBool();

		if (extraHeader1)
		{
			frequencyScale = input.readBits(2);
			alterScale = input.readBool();
			noiseBands = input.readBits(2);
		}
		else
		{
			frequencyScale = 2;
			alterScale = true;
			noiseBands = 2;
		}

		if (extraHeader2)
		{
			limiterBands = input.readBits(2);
			limiterGains = input.readBits(2);
			interpolFrequency = input.readBool();
			smoothingMode = input.readBool();
		}
		else
		{
			limiterBands = 2;
			limiterGains = 2;
			interpolFrequency = true;
			smoothingMode = true;
		}
	}

	//calculates the master frequency table
	private function calculateTables()
	{
		k0 = Calculation.getStartChannel(startFrequency, sampleRate);
		var k2 : Int = Calculation.getStopChannel(stopFrequency, sampleRate, k0);

		//check k0 and k2 (MFT length)
		var len : Int = k2-k0;
		var maxLen : Int;
		if(sampleRate>=48000) maxLen = 32;
		else if(sampleRate<=32000) maxLen = 48;
		else maxLen = 45;

		if (len <= maxLen)
		{
			var table : Vector<Int>;
			if(frequencyScale==0) table = Calculation.calculateMasterFrequencyTableFS0(k0, k2, alterScale);
			else table = Calculation.calculateMasterFrequencyTable(k0, k2, frequencyScale, alterScale);
			if (table != null)
			{
				mft = table;
				N_master = table.length-1;
			}

			calculateDerivedFrequencyTable(k2);
		}
		else throw ("SBR: master frequency table too long: "+len+", max. length: "+maxLen);
	}

	//calculates the derived frequency border table from the master table
	private function calculateDerivedFrequencyTable(k2 : Int)
	{
		if(N_master<=xOverBand) throw("SBR: derived frequency table: N_master="+N_master+", xOverBand="+xOverBand);
		//int i;

		N_high = N_master-xOverBand;
		N_low = (N_high>>1)+(N_high-((N_high>>1)<<1));

		n[0] = N_low;
		n[1] = N_high;

		//fill high resolution table
		for (i in 0...(N_high + 1))
		{
			ftRes[SBRConstants.HI_RES][i] = mft[i+xOverBand];
		}

		M = ftRes[SBRConstants.HI_RES][N_high]-ftRes[SBRConstants.HI_RES][0];
		kx = ftRes[SBRConstants.HI_RES][0];
		if(kx>32) throw("SBR: kx>32: "+kx);
		if(kx+M>64) throw("SBR: kx+M>64: "+(kx+M));

		//fill low resolution table
		var minus : Int = N_high&1;
		var x : Int = 0;
		for (i in 0...(N_low+1))
		{
			x = (i==0) ? 0 : 2*i-minus;
			ftRes[SBRConstants.LO_RES][i] = ftRes[SBRConstants.HI_RES][x];
		}

		if(noiseBands==0) N_Q = 1;
		else N_Q = IntMath.min(5, IntMath.max(1, Calculation.findBands(false, noiseBands, kx, k2)));

		//fill noise table
		for (i in 0...(N_Q+1))
		{
			x = (i==0) ? 0 : x+IntDivision.intDiv(N_low-x,N_Q+1-i);
			ftNoise[i] = ftRes[SBRConstants.LO_RES][x];
		}

		//build table for mapping k to g in HF patching
		//int j;
		for (i in 0...64)
		{
			for (j in 0...N_Q)
			{
				if ((ftNoise[j] <= i) && (i < ftNoise[j + 1]))
				{
					tableMapKToG[i] = j;
					break;
				}
			}
		}
	}

	//fills ftLim and N_L
	public function calculateLimiterFrequencyTable()
	{
		ftLim[0][0] = ftRes[SBRConstants.LO_RES][0]-kx;
		ftLim[0][1] = ftRes[SBRConstants.LO_RES][N_low]-kx;
		N_L[0] = 1;

		//int j;
		//calculate patch borders
		var patchBorders : Vector<Int> = new Vector<Int>(patches+1);
		patchBorders[0] = kx;
		for (j in 1...(patches+1))
		{
			patchBorders[j] = patchBorders[j-1]+patchNoSubbands[j-1];
		}

		var limTable : Vector<Int> = new Vector<Int>(patches+N_low);
		//int k, limCount;
		var limCount : Int;
		var octaves : Float;
		//fill N_L[i]
		for (i in 1...4)
		{
			//set up limTable
			//System.arraycopy(ftRes[LO_RES], 0, limTable, 0, N_low+1);
			VectorTools.vectorcopyI(ftRes[SBRConstants.LO_RES], 0, limTable, 0, N_low+1);
			//System.arraycopy(patchBorders, 1, limTable, N_low+1, patches-1);
			VectorTools.vectorcopyI(patchBorders, 1, limTable, N_low+1, patches-1);
			//Arrays.sort(limTable, 0, patches + N_low); //needed!
			VectorTools.sortI(limTable, 0, patches + N_low);

			limCount = patches+N_low-1;
			if (limCount < 0) return;
			
			var j : Int = 1;
			while (j <= limCount)
			{
				if(limTable[j-1]!=0) octaves = limTable[j]/limTable[j-1];
				else octaves = 0;

				if (octaves < SBRTables.LIMITER_BANDS_COMPARE[i - 1])
				{
					if (limTable[j] != limTable[j - 1])
					{
						var found : Bool = false;
						for (k in 0...(patches + 1))
						{
							if (limTable[j] == patchBorders[k])
							{
								found = false;
								for (k in 0...(patches+1))
								{
									if(limTable[j-1]==patchBorders[k]) found = true;
								}
								if (found)
								{
									j++;
									continue;
								}
								else
								{
									//remove (k-1)th element
									limTable[j-1] = ftRes[SBRConstants.LO_RES][N_low];
									//Arrays.sort(limTable, 0, patches+N_low);
									VectorTools.sortI(limTable, 0, patches+N_low);
									limCount--;
									continue;
								}
							}
						}
					}

					//remove jth element
					limTable[j] = ftRes[SBRConstants.LO_RES][N_low];
					//Arrays.sort(limTable, 0, limCount);
					VectorTools.sortI(limTable, 0, limCount);
					limCount--;
					continue;
				}
				else j++;
			}

			N_L[i] = limCount;
			for (j in 0...(limCount+1))
			{
				ftLim[i][j] = limTable[j]-kx;
			}
		}
	}

	private function decodeData(input : BitStream, stereo : Bool)
	{
		if(stereo) decodeChannelPairElement(input);
		else decodeSingleChannelElement(input);

		//extended data
		if (input.readBool())
		{
			psExtensionRead = false;
			var count : Int = input.readBits(4);
			if(count==15) count += input.readBits(8);

			var bitsLeft : Int = 8*count;
			while (bitsLeft > 7)
			{
				bitsLeft -= 2;
				extensionID = input.readBits(2);
				if(extensionID==SBRConstants.EXTENSION_ID_PS&&psExtensionRead) extensionID = 3;
				bitsLeft -= decodeExtension(input, extensionID);
			}
			if(bitsLeft>0) input.skipBits(bitsLeft);
		}
	}

	private function decodeSingleChannelElement(input : BitStream)
	{
		if(input.readBool()) input.skipBits(4); //reserved

		cd[0].decodeGrid(input);
		cd[0].decodeDTDF(input);
		cd[0].decodeInvfMode(input, N_Q);
		cd[0].decodeEnvelope(input, this, 0);
		cd[0].decodeNoise(input, this, 0);
		cd[0].decodeSinusoidalCoding(input, N_high);

		dequantEnvelopeNoise(0);
	}

	private function decodeChannelPairElement(input : BitStream)
	{
		if(input.readBool()) input.skipBits(8); //reserved

		if (coupling = input.readBool())
		{
			cd[0].decodeGrid(input);
			cd[1].copyGrid(cd[0]);
			cd[0].decodeDTDF(input);
			cd[1].decodeDTDF(input);
			cd[0].decodeInvfMode(input, N_Q);
			cd[1].copyInvfMode(cd[0], N_Q);
			cd[0].decodeEnvelope(input, this, 0);
			cd[0].decodeNoise(input, this, 0);
			cd[1].decodeEnvelope(input, this, 1);
			cd[1].decodeNoise(input, this, 1);
			cd[0].decodeSinusoidalCoding(input, N_high);
			cd[1].decodeSinusoidalCoding(input, N_high);
		}
		else
		{
			cd[0].decodeGrid(input);
			cd[1].decodeGrid(input);
			cd[0].decodeDTDF(input);
			cd[1].decodeDTDF(input);
			cd[0].decodeInvfMode(input, N_Q);
			cd[1].decodeInvfMode(input, N_Q);
			cd[0].decodeEnvelope(input, this, 0);
			cd[1].decodeEnvelope(input, this, 1);
			cd[0].decodeNoise(input, this, 0);
			cd[1].decodeNoise(input, this, 1);
			cd[0].decodeSinusoidalCoding(input, N_high);
			cd[1].decodeSinusoidalCoding(input, N_high);
		}

		dequantEnvelopeNoise(0);
		dequantEnvelopeNoise(1);

		if(coupling) unmapEnvelopeNoise();
	}

	private function decodeExtension(input : BitStream, extensionID : Int)
	{
		var ret : Int;

		switch(extensionID)
		{
			case SBRConstants.EXTENSION_ID_PS:
			{
				if(!psExtensionRead) psExtensionRead = true;
				if(ps==null) ps = new PS(sampleRate);
				ret = ps.decode(input);
				if(!psUsed&&ps.hasHeader()) psUsed = true;
			}
			default:
			{
				extensionData = input.readBits(6);
				ret = 6;
			}
		}
		return ret;
	}

	private function reset_()
	{
		reset = ((startFrequency!=startFrequencyPrev)
				||(stopFrequency!=stopFrequencyPrev)
				||(frequencyScale!=frequencyScalePrev)
				||(alterScale!=alterScalePrev)
				||(xOverBand!=xOverBandPrev)
				||(noiseBands!=noiseBandsPrev));

		startFrequencyPrev = startFrequency;
		stopFrequencyPrev = stopFrequency;
		frequencyScalePrev = frequencyScale;
		alterScalePrev = alterScale;
		xOverBandPrev = xOverBand;
		noiseBandsPrev = noiseBands;

		if(reset) calculateTables();
	}

	/* ================== dequant/unmap ================== */
	//dequantizes envelope and noise values
	private function dequantEnvelopeNoise(ch : Int)
	{
		var c : ChannelData = cd[ch];
		if (!coupling)
		{
			var amp : Int = c.ampRes ? 0 : 1;
			//int exp, i, j;
			var j : Int;
			var exp : Int;

			for (i in 0...c.L_E)
			{
				j = 0;
				while (j < n[c.f[i] ? 1 : 0])
				{
					exp = c.E[j][i]>>amp;
					if((exp<0)||(exp>=64)) c.E_orig[j][i] = 0;
					else
					{
						c.E_orig[j][i] = SBRTables.ENVELOPE_DEQUANT_TABLE[exp];
						if(amp!=0&&(c.E[j][i]&1)==1) c.E_orig[j][i] *= Constants.SQRT2;
					}
					j++;
				}
			}

			for (i in 0...c.L_Q)
			{
				for (j in 0...N_Q)
				{
					c.Q_div[j][i] = calculateQDiv(ch, j, i);
					c.Q_div2[j][i] = calculateQDiv2(ch, j, i);
				}
			}
		}
	}

	//unmaps envelope and noise values
	private function unmapEnvelopeNoise()
	{
		var amp0 : Int = cd[0].ampRes ? 0 : 1;
		var amp1 : Int = cd[1].ampRes ? 0 : 1;

		//int i, j, exp0, exp1;
		var exp0 : Int;
		var exp1 : Int;
		var tmp : Float;
		var j : Int;
		for (i in 0...cd[0].L_E)
		{
			j = 0;
			while (j < n[cd[0].f[i] ? 1 : 0])
			{
				exp0 = (cd[0].E[j][i]>>amp0)+1;
				exp1 = (cd[1].E[j][i]>>amp1);

				if ((exp0<0)||(exp0>=64)||(exp1<0)||(exp1>24))
				{
					cd[1].E_orig[j][i] = 0;
					cd[0].E_orig[j][i] = 0;
				}
				else
				{
					tmp = SBRTables.ENVELOPE_DEQUANT_TABLE[exp0];
					if(amp0!=0&&(cd[0].E[j][i]&1)==1) tmp *= Constants.SQRT2;

					//panning
					cd[0].E_orig[j][i] = tmp*SBRTables.ENVELOPE_PANNING_TABLE[exp1];
					cd[1].E_orig[j][i] = tmp*SBRTables.ENVELOPE_PANNING_TABLE[24-exp1];
				}
				j++;
			}
		}

		for (i in 0...cd[0].L_Q)
		{
			for (j in 0...N_Q)
			{
				cd[0].Q_div[j][i] = calculateQDiv(0, j, i);
				cd[1].Q_div[j][i] = calculateQDiv(1, j, i);
				cd[0].Q_div2[j][i] = calculateQDiv2(0, j, i);
				cd[1].Q_div2[j][i] = calculateQDiv2(1, j, i);
			}
		}
	}

	//calculates 1/(1+Q), [0..1]
	private function calculateQDiv(ch : Int, m : Int, l : Int) : Float
	{
		if (coupling)
		{
			if((cd[0].Q[m][l]<0||cd[0].Q[m][l]>30)||(cd[1].Q[m][l]<0||cd[1].Q[m][l]>24)) return 0;
			else
			{
				if(ch==0) return SBRTables.Q_DIV_TABLE_LEFT[cd[0].Q[m][l]][cd[1].Q[m][l]>>1];
				else return SBRTables.Q_DIV_TABLE_RIGHT[cd[0].Q[m][l]][cd[1].Q[m][l]>>1];
			}
		}
		else
		{
			if(cd[ch].Q[m][l]<0||cd[ch].Q[m][l]>30) return 0;
			else return SBRTables.Q_DIV_TABLE[cd[ch].Q[m][l]];
		}
	}

	//calculates Q/(1+Q), [0..1]
	private function calculateQDiv2(ch : Int, m : Int, l : Int) : Float {
		if (coupling)
		{
			if((cd[0].Q[m][l]<0||cd[0].Q[m][l]>30)||(cd[1].Q[m][l]<0||cd[1].Q[m][l]>24)) return 0;
			else
			{
				if(ch==0) return SBRTables.Q_DIV2_TABLE_LEFT[cd[0].Q[m][l]][cd[1].Q[m][l]>>1];
				else return SBRTables.Q_DIV2_TABLE_RIGHT[cd[0].Q[m][l]][cd[1].Q[m][l]>>1];
			}
		}
		else
		{
			if(cd[ch].Q[m][l]<0||cd[ch].Q[m][l]>30) return 0;
			else return SBRTables.Q_DIV2_TABLE[cd[ch].Q[m][l]];
		}
	}

	/* ================== processing ================== */
	public function isPSUsed() : Bool
	{
		return psUsed;
	}

	public function processSingleFrame(channel : Vector<Float>, downSampled : Bool)
	{
		//if(buffer==null) buffer = new float[TIME_SLOTS_RATE][64][2];
		if (buffer == null) buffer = VectorTools.new3DMatrixVectorF(SBRConstants.TIME_SLOTS_RATE, 64, 2);
		var process : Bool = true;

		if (headerCount == 0)
		{
			//don't process just upsample
			process = false;
			//re-activate reset for next frame
			if(reset) startFrequencyPrev = -1;
		}

		processChannel(channel, buffer, 0, process);
		//subband synthesis
		if(downSampled) qmfs[0].performSynthesis32(buffer, channel, SBRConstants.TIME_SLOTS_RATE);
		else qmfs[0].performSynthesis64(buffer, channel, SBRConstants.TIME_SLOTS_RATE);

		if(headerCount!=0) savePreviousData(0);

		cd[0].saveMatrix();
	}

	public function processCoupleFrame(left : Vector<Float>, right : Vector<Float>, downSampled : Bool)
	{
		//if(buffer==null) buffer = new float[TIME_SLOTS_RATE][64][2];
		if (buffer == null) buffer = VectorTools.new3DMatrixVectorF(SBRConstants.TIME_SLOTS_RATE, 64, 2);
		var process : Bool = true;

		if (headerCount == 0)
		{
			//don't process just upsample
			process = false;
			//re-activate reset for next frame
			if(reset) startFrequencyPrev = -1;
		}

		processChannel(left, buffer, 0, process);
		if(downSampled) qmfs[0].performSynthesis32(buffer, left, SBRConstants.TIME_SLOTS_RATE);
		else qmfs[0].performSynthesis64(buffer, left, SBRConstants.TIME_SLOTS_RATE);

		if(qmfs[1]==null) qmfs[1] = new QMFSynthesis(filterBank, downSampled ? 32 : 64);

		processChannel(right, buffer, 1, process);
		if(downSampled) qmfs[1].performSynthesis32(buffer, right, SBRConstants.TIME_SLOTS_RATE);
		else qmfs[1].performSynthesis64(buffer, right, SBRConstants.TIME_SLOTS_RATE);

		if (headerCount != 0)
		{
			savePreviousData(0);
			savePreviousData(1);
		}

		cd[0].saveMatrix();
		cd[1].saveMatrix();
	}

	public function processSingleFramePS(left : Vector<Float>, right : Vector<Float>, downSampled : Bool)
	{
		if (bufLeftPS == null)
		{
			//bufLeftPS = new float[38][64][2];
			bufLeftPS = VectorTools.new3DMatrixVectorF(38, 64, 2);
			//bufRightPS = new float[38][64][2];
			bufRightPS = VectorTools.new3DMatrixVectorF(38, 64, 2);
		}
		var process : Bool = true;
		if (headerCount == 0)
		{
			//don't process just upsample
			process = false;
			//re-activate reset for next frame
			startFrequencyPrev = -1;
		}

		processChannel(left, bufLeftPS, 0, process);
		
		//copy extra data for PS
		//int k;
		for (l in SBRConstants.TIME_SLOTS_RATE...(SBRConstants.TIME_SLOTS_RATE + 6))
		{
			for (k in 0...5)
			{
				bufLeftPS[l][k][0] = cd[0].Xsbr[SBRConstants.T_HFADJ+l][k][0];
				bufLeftPS[l][k][1] = cd[0].Xsbr[SBRConstants.T_HFADJ+l][k][1];
			}
		}

		//perform parametric stereo		
		ps.process(bufLeftPS, bufRightPS);

		if(qmfs[1]==null) qmfs[1] = new QMFSynthesis(filterBank, downSampled ? 32 : 64);
		//subband synthesis
		if (downSampled)
		{
			qmfs[0].performSynthesis32(bufLeftPS, left, SBRConstants.TIME_SLOTS_RATE);
			qmfs[1].performSynthesis32(bufRightPS, right, SBRConstants.TIME_SLOTS_RATE);
		}
		else
		{
			qmfs[0].performSynthesis64(bufLeftPS, left, SBRConstants.TIME_SLOTS_RATE);
			qmfs[1].performSynthesis64(bufRightPS, right, SBRConstants.TIME_SLOTS_RATE);
		}

		if (headerCount != 0) savePreviousData(0);
		cd[0].saveMatrix();		
	}

	private function processChannel(channel : Vector<Float>, X : Vector<Vector<Vector<Float>>>, ch : Int, process : Bool)
	{
		//int i, j;

		//subband analysis
		var param : Int = process ? kx : 32;
		if (qmfa[ch] == null) qmfa[ch] = new QMFAnalysis(filterBank, 32);
		
		qmfa[ch].performAnalysis32(channel, cd[ch].Xsbr, SBRConstants.T_HFGEN, param, SBRConstants.TIME_SLOTS_RATE);

		if (process)
		{
			hfGen.process(cd[ch].Xsbr, cd[ch].Xsbr, ch, cd[ch]);
			hfAdj.process(cd[ch].Xsbr, cd[ch]);
			
			var kx_band : Int;
			var M_band : Int;
			for (i in 0...SBRConstants.TIME_SLOTS_RATE)
			{
				if (i < cd[ch].t_E[0])
				{
					kx_band = kxPrev;
					M_band = Mprev;
				}
				else
				{
					kx_band = kx;
					M_band = M;
				}

				for (j in 0...kx_band)
				{
					X[i][j][0] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][0];
					X[i][j][1] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][1];
				}
				for (j in kx_band...(kx_band + M_band))
				{
					X[i][j][0] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][0];
					X[i][j][1] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][1];
				}
				for (j in (kx_band + M_band)...64)
				{
					X[i][j][0] = 0;
					X[i][j][1] = 0;
				}
			}
		}
		else
		{
			for (i in 0...SBRConstants.TIME_SLOTS_RATE)
			{
				for (j in 0...32)
				{
					X[i][j][0] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][0];
					X[i][j][1] = cd[ch].Xsbr[i+SBRConstants.T_HFADJ][j][1];
				}
				for (j in 32...64)
				{
					X[i][j][0] = 0;
					X[i][j][1] = 0;
				}
			}
		}
	}

	private function savePreviousData(ch : Int)
	{
		//save data for next frame
		kxPrev = kx;
		Mprev = M;
		cd[ch].savePreviousData();		
	}
	
}