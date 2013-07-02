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

package impl.ps;
import flash.Vector;
import impl.BitStream;
import impl.IntDivision;
import impl.IntMath;
import impl.VectorTools;

class PS 
{

	//bitstream
	private var frameClass : Bool;
	private var envCount : Int;
	private var borderPosition : Vector<Int>;
	private var iidEnabled : Bool;
	private var iccEnabled : Bool;
	private var extEnabled : Bool;
	private var ipdopdEnabled : Bool;
	private var iidMode : Int;
	private var iccMode : Int;
	private var ipdMode : Int;
	private var iidPars : Int;
	private var iccPars : Int;
	private var ipdopdPars : Int;
	private var iidTime : Vector<Bool>;
	private var iccTime : Vector<Bool>;
	private var vipdTime : Vector<Bool>;
	private var ipdTime : Vector<Bool>;
	private var opdTime : Vector<Bool>;
	//indices
	private var iidIndex : Vector<Vector<Int>>;
	private var iccIndex : Vector<Vector<Int>>;
	private var ipdIndex : Vector<Vector<Int>>;
	private var opdIndex : Vector<Vector<Int>>;
	private var iidIndexPrev : Vector<Int>;
	private var iccIndexPrev : Vector<Int>;
	private var ipdIndexPrev : Vector<Int>;
	private var opdIndexPrev : Vector<Int>;
	private var dataAvailable : Bool;
	private var header : Bool;
	//hybrid filterbank
	private var bufferLeft : Vector<Vector<Vector<Float>>>;
	private var bufferRight : Vector<Vector<Vector<Float>>>; //main processing buffers
	private var filterBank : FilterBank;
	private var use34 : Bool;
	private var groups : Int;
	private var hybridGroups : Int;
	private var parBands : Int;
	private var decayCutoff : Int;
	private var groupBorder : Array<Int>;
	private var mapGroupToBK : Array<Int>;
	//filter delay handling
	private var savedDelay : Int;
	private var delayBufIndexSer : Vector<Int>;
	private var sampleDelaySerCount : Vector<Int>;
	private var delayD : Vector<Int>;
	private var delayBufIndexDelay : Vector<Int>;
	private var delayQMF : Vector<Vector<Vector<Float>>>;
	private var delaySubQMF : Vector<Vector<Vector<Float>>>;
	private var delayQMFSer : Vector<Vector<Vector<Vector<Float>>>>;
	private var delaySubQMFSer : Vector<Vector<Vector<Vector<Float>>>>;
	//transients
	private var peakDecayEnergy : Vector<Float>;
	private var pPrev : Vector<Float>;
	private var smoothPeakDecayDiffEnergyPrev : Vector<Float>;
	//mixing and phase
	private var phaseHist : Int;
	private var h11Prev : Vector<Vector<Float>>;
	private var h12Prev : Vector<Vector<Float>>;
	private var h21Prev : Vector<Vector<Float>>;
	private var h22Prev : Vector<Vector<Float>>;
	private var ipdPrev : Vector<Vector<Vector<Float>>>;
	private var opdPrev : Vector<Vector<Vector<Float>>>;
	private var iidSteps : Int;
	private var sfIID : Array<Float>;
	
	public function new(sampleRate : Int)
	{
		//init arrays
		borderPosition = new Vector<Int>(PSConstants.MAX_PS_ENVELOPES+1);
		iidTime = new Vector<Bool>(PSConstants.MAX_PS_ENVELOPES);
		iccTime = new Vector<Bool>(PSConstants.MAX_PS_ENVELOPES);
		ipdTime = new Vector<Bool>(PSConstants.MAX_PS_ENVELOPES);
		opdTime = new Vector<Bool>(PSConstants.MAX_PS_ENVELOPES);
		iidIndexPrev = new Vector<Int>(34);
		iccIndexPrev = new Vector<Int>(34);
		ipdIndexPrev = new Vector<Int>(17);
		opdIndexPrev = new Vector<Int>(17);
		//iidIndex = new int[MAX_PS_ENVELOPES][34];
		iidIndex = VectorTools.newMatrixVectorI(PSConstants.MAX_PS_ENVELOPES, 34);
		//iccIndex = new int[MAX_PS_ENVELOPES][34];
		iccIndex = VectorTools.newMatrixVectorI(PSConstants.MAX_PS_ENVELOPES, 34);
		//ipdIndex = new int[MAX_PS_ENVELOPES][17];
		ipdIndex = VectorTools.newMatrixVectorI(PSConstants.MAX_PS_ENVELOPES, 17);
		//opdIndex = new int[MAX_PS_ENVELOPES][17];
		opdIndex = VectorTools.newMatrixVectorI(PSConstants.MAX_PS_ENVELOPES, 17);
		delayBufIndexSer = new Vector<Int>(PSConstants.NO_ALLPASS_LINKS);
		sampleDelaySerCount = new Vector<Int>(PSConstants.NO_ALLPASS_LINKS);
		delayD = new Vector<Int>(64);
		delayBufIndexDelay = new Vector<Int>(64);
		//delayQMF = new float[14][64][2]; //14 samples delay max, 64 QMF channels, complex
		delayQMF = VectorTools.new3DMatrixVectorF(14, 64, 2);
		//delaySubQMF = new float[2][32][2]; //2 samples delay max, complex
		delaySubQMF = VectorTools.new3DMatrixVectorF(2, 32, 2);
		//delayQMFSer = new float[NO_ALLPASS_LINKS][5][64][2]; //5 samples delay max, 64 QMF channels, complex
		delayQMFSer = VectorTools.new4DMatrixVectorF(PSConstants.NO_ALLPASS_LINKS, 5, 54, 2);
		//delaySubQMFSer = new float[NO_ALLPASS_LINKS][5][32][2]; //5 samples delay max, complex
		delaySubQMFSer = VectorTools.new4DMatrixVectorF(PSConstants.NO_ALLPASS_LINKS, 5, 32, 2);
		peakDecayEnergy = new Vector<Float>(34);
		pPrev = new Vector<Float>(34);
		smoothPeakDecayDiffEnergyPrev = new Vector<Float>(34);
		//h11Prev = new float[50][2];
		h11Prev = VectorTools.newMatrixVectorF(50, 2);
		//h12Prev = new float[50][2];
		h12Prev = VectorTools.newMatrixVectorF(50, 2);
		//h21Prev = new float[50][2];
		h21Prev = VectorTools.newMatrixVectorF(50, 2);
		//h22Prev = new float[50][2];
		h22Prev = VectorTools.newMatrixVectorF(50, 2);
		//ipdPrev = new float[20][2][2];
		ipdPrev = VectorTools.new3DMatrixVectorF(20, 2, 2);
		//opdPrev = new float[20][2][2];
		opdPrev = VectorTools.new3DMatrixVectorF(20, 2, 2);
		//bufferLeft = new float[32][32][2];
		bufferLeft = VectorTools.new3DMatrixVectorF(32, 32, 2);
		//bufferRight = new float[32][32][2];
		bufferRight = VectorTools.new3DMatrixVectorF(32, 32, 2);
		//
		filterBank = new FilterBank();
		dataAvailable = false;
		savedDelay = 0;

		for (i in 0...PSConstants.NO_ALLPASS_LINKS)
		{
			sampleDelaySerCount[i] = PSTables.DELAY_LENGTH_D[i];
		}
		for (i in 0...PSConstants.SHORT_DELAY_BAND)
		{
			delayD[i] = 14;
		}
		for (i in PSConstants.SHORT_DELAY_BAND...64)
		{
			delayD[i] = 1;
		}

		//mixing and phase
		for (i in 0...50)
		{
			h11Prev[i][0] = 1;
			h12Prev[i][1] = 1;
			h11Prev[i][0] = 1;
			h12Prev[i][1] = 1;
		}
		phaseHist = 0;
	}
	
	//============= decoding =============
	public function decode(input : BitStream) : Int
	{
		var bits : Int = input.getPosition();

		//check for new header
		if (input.readBool())
		{
			if(!header) header = true;
			dataAvailable = true;
			use34 = false;

			//read flags and modes
			//Inter-channel Intensity Difference (IID)
			if (iidEnabled = input.readBool())
			{
				iidMode = input.readBits(3);
				if(iidMode==2||iidMode==5) use34 = true;
				iidPars = PSTables.NR_IID_PAR_TAB[iidMode];
				ipdopdPars = PSTables.NR_IPDOPD_PAR_TAB[iidMode];
				ipdMode = iidMode;
			}

			//Inter-channel Coherence (ICC)
			if (iccEnabled = input.readBool())
			{
				iccMode = input.readBits(3);
				iccPars = PSTables.NR_ICC_PAR_TAB[iccMode];
				if(iccMode==2||iccMode==5) use34 = true;
			}

			//extensions
			extEnabled = input.readBool();
		}

		frameClass = input.readBool();
		envCount = PSTables.NUM_ENV_TAB[frameClass ? 1 : 0][input.readBits(2)];
		if (frameClass)
		{
			for (n in 1...(envCount + 1))
			{
				borderPosition[n] = input.readBits(5)+1;
			}
		}

		//read huffman data
		if (iidEnabled)
		{
			for (n in 0...envCount)
			{
				iidTime[n] = input.readBool();
				if(iidMode<3) Huffman.decode(input, iidTime[n], iidPars, HuffmanTables.T_HUFF_IID_DEF, HuffmanTables.F_HUFF_IID_DEF, iidIndex[n]);
				else Huffman.decode(input, iidTime[n], iidPars, HuffmanTables.T_HUFF_IID_FINE, HuffmanTables.F_HUFF_IID_FINE, iidIndex[n]);
			}
		}

		if (iccEnabled)
		{
			for (n in 0...envCount)
			{
				iccTime[n] = input.readBool();
				Huffman.decode(input, iccTime[n], iccPars, HuffmanTables.T_HUFF_ICC, HuffmanTables.F_HUFF_ICC, iccIndex[n]);
			}
		}

		if (extEnabled)
		{
			var cnt : Int = input.readBits(4);
			if(cnt==15) cnt += input.readBits(8);

			var bitsLeft : Int = 8*cnt;
			var extensionID : Int;
			while (bitsLeft > 7)
			{
				extensionID = input.readBits(2);
				bitsLeft -= 2;
				bitsLeft -= decodeExtension(input, extensionID);
			}
			input.skipBits(bitsLeft);
		}

		return input.getPosition()-bits;
	}
	
	private function decodeExtension(input : BitStream, extensionID : Int) : Int
	{
		var bits : Int = input.getPosition();

		if (extensionID == PSConstants.EXTENSION_ID_IPDOPD)
		{
			if (ipdopdEnabled = input.readBool())
			{
				for (n in 0...envCount)
				{
					ipdTime[n] = input.readBool();
					Huffman.decode(input, ipdTime[n], ipdopdPars, HuffmanTables.T_HUFF_IPD, HuffmanTables.F_HUFF_IPD, ipdIndex[n]);
					opdTime[n] = input.readBool();
					Huffman.decode(input, opdTime[n], ipdopdPars, HuffmanTables.T_HUFF_OPD, HuffmanTables.F_HUFF_OPD, opdIndex[n]);
				}
			}
			input.skipBit(); //reserved
		}

		return input.getPosition()-bits;
	}
	
	public function hasHeader() : Bool
	{
		return header;
	}
	
	//============= processing =============
	public function process(left : Vector<Vector<Vector<Float>>>, right : Vector<Vector<Vector<Float>>>)
	{
		//delta decoding of the bitstream data
		parseData();

		//set up parameters depending on filterbank type
		if (use34)
		{
			groupBorder = PSTables.GROUP_BORDER34;
			mapGroupToBK = PSTables.MAP_GROUP2BK34;
			groups = 32+18;
			hybridGroups = 32;
			parBands = 34;
			decayCutoff = 5;
		}
		else
		{
			groupBorder = PSTables.GROUP_BORDER20;
			mapGroupToBK = PSTables.MAP_GROUP2BK20;
			groups = 10+12;
			hybridGroups = 10;
			parBands = 20;
			decayCutoff = 3;
		}

		//perform further analysis on the lowest subbands to get a higher frequency resolution
		filterBank.performAnalysis(left, bufferLeft, use34);

		//decorrelate mono signal
		decorrelate(left, right, bufferLeft, bufferRight);

		//apply mixing and phase parameters
		mixPhase(left, right, bufferLeft, bufferRight);

		//hybrid synthesis, to rebuild the SBR QMF matrices
		filterBank.performSynthesis(bufferLeft, left, use34);
		filterBank.performSynthesis(bufferRight, right, use34);
	}
	
	//============= parsing =============
	//parses the decoded bitstream data
	private function parseData()
	{
		//if no data available, use data from previous frame
		if(!dataAvailable) envCount = 0;

		//set iidSteps and sfIID
		if (iidMode >= 3)
		{
			iidSteps = PSConstants.IID_STEPS_LONG;
			sfIID = PSTables.SF_IID_FINE;
		}
		else
		{
			iidSteps = PSConstants.IID_STEPS_SHORT;
			sfIID = PSTables.SF_IID_NORMAL;
		}

		//int i, j;
		//int[] iid, icc, ipd, opd;
		var iid : Vector<Int>;
		var icc : Vector<Int>;
		var ipd : Vector<Int>;
		var opd : Vector<Int>;
		for (i in 0...envCount)
		{
			if (i == 0)
			{
				iid = iidIndexPrev;
				icc = iccIndexPrev;
				ipd = ipdIndexPrev;
				opd = opdIndexPrev;
			}
			else
			{
				iid = iidIndex[i-1];
				icc = iccIndex[i-1];
				ipd = ipdIndex[i-1];
				opd = opdIndex[i-1];
			}

			deltaDecode(iidEnabled, iidIndex[i], iid, iidTime[i],
					iidPars, (iidMode==0||iidMode==3) ? 2 : 1, -iidSteps, iidSteps);
			deltaDecode(iccEnabled, iccIndex[i], icc, iccTime[i],
					iccPars, (iccMode==0||iccMode==3) ? 2 : 1, 0, 7);
			deltaModuloDecode(ipdopdEnabled, ipdIndex[i], ipd,
					ipdTime[i], ipdopdPars, 1, 7);
			deltaModuloDecode(ipdopdEnabled, opdIndex[i], opd,
					opdTime[i], ipdopdPars, 1, 7);
		}

		if (envCount == 0)
		{
			//error case
			envCount = 1;

			if (iidEnabled)
			{
				for (j in 0...34)
				{
					iidIndex[0][j] = iidIndexPrev[j];
				}
			}
			else
			{
				for (j in 0...34)
				{
					iidIndex[0][j] = 0;
				}
			}

			if (iccEnabled)
			{
				for (j in 0...34)
				{
					iccIndex[0][j] = iccIndexPrev[j];
				}
			}
			else
			{
				for (j in 0...34)
				{
					iccIndex[0][j] = 0;
				}
			}

			if (ipdopdEnabled)
			{
				for (j in 0...17)
				{
					ipdIndex[0][j] = ipdIndexPrev[j];
					opdIndex[0][j] = opdIndexPrev[j];
				}
			}
			else
			{
				for (j in 0...17)
				{
					ipdIndex[0][j] = 0;
					opdIndex[0][j] = 0;
				}
			}
		}

		//update previous indices
		//System.arraycopy(iidIndex[envCount-1], 0, iidIndexPrev, 0, 34);
		VectorTools.vectorcopyI(iidIndex[envCount-1], 0, iidIndexPrev, 0, 34);
		//System.arraycopy(iccIndex[envCount-1], 0, iccIndexPrev, 0, 34);
		VectorTools.vectorcopyI(iccIndex[envCount-1], 0, iccIndexPrev, 0, 34);
		//System.arraycopy(ipdIndex[envCount-1], 0, ipdIndexPrev, 0, 17);
		VectorTools.vectorcopyI(ipdIndex[envCount-1], 0, ipdIndexPrev, 0, 17);
		//System.arraycopy(opdIndex[envCount-1], 0, opdIndexPrev, 0, 17);
		VectorTools.vectorcopyI(opdIndex[envCount-1], 0, opdIndexPrev, 0, 17);

		dataAvailable = false;

		borderPosition[0] = 0;
		if (!frameClass)
		{
			for (i in 1...envCount)
			{
				borderPosition[i] = IntDivision.intDiv((i*PSConstants.TIME_SLOTS_RATE), envCount);
			}
			borderPosition[envCount] = PSConstants.TIME_SLOTS_RATE;
		}
		else {
			if (borderPosition[envCount] < PSConstants.TIME_SLOTS_RATE)
			{
				//System.arraycopy(iidIndex[envCount-1], 0, iidIndex[envCount], 0, 34);
				VectorTools.vectorcopyI(iidIndex[envCount-1], 0, iidIndex[envCount], 0, 34);
				//System.arraycopy(iccIndex[envCount-1], 0, iccIndex[envCount], 0, 17);
				VectorTools.vectorcopyI(iccIndex[envCount-1], 0, iccIndex[envCount], 0, 17);
				envCount++;
				borderPosition[envCount] = PSConstants.TIME_SLOTS_RATE;
			}

			var thr : Int;
			for (i in 1...envCount)
			{
				thr = PSConstants.TIME_SLOTS_RATE-(envCount-i);

				if(borderPosition[i]>thr) borderPosition[i] = thr;
				else
				{
					thr = borderPosition[i-1]+1;
					if(borderPosition[i]<thr) borderPosition[i] = thr;
				}
			}
		}

		/* make sure that the indices of all parameters can be mapped
		 * to the same hybrid synthesis filterbank */
		if (use34)
		{
			for (i in 0...envCount)
			{
				if(iidMode!=2&&iidMode!=5) map20IndexTo34(iidIndex[i], 34);
				if(iccMode!=2&&iccMode!=5) map20IndexTo34(iccIndex[i], 34);
				if (ipdMode != 2 && ipdMode != 5)
				{
					map20IndexTo34(ipdIndex[i], 17);
					map20IndexTo34(opdIndex[i], 17);
				}
			}
		}
	}
	
	private function deltaDecode(enabled : Bool, index : Vector<Int>, indexPrev : Vector<Int>,
			time : Bool, parCount : Int, stride : Int, minIndex : Int, maxIndex : Int)
	{
		if (enabled)
		{
			if (!time)
			{
				index[0] = IntMath.min(maxIndex, IntMath.max(index[0], minIndex));
				for (i in 1...parCount)
				{
					index[i] = index[i-1]+index[i];
					index[i] = IntMath.min(maxIndex, IntMath.max(index[i], minIndex));
				}
			}
			else {
				for (i in 0...parCount)
				{
					index[i] = indexPrev[i*stride]+index[i];
					index[i] = IntMath.min(maxIndex, IntMath.max(index[i], minIndex));
				}
			}
		}
		else
		{
			for (i in 0...parCount)
			{
				index[i] = 0;
			}
		}

		//coarse
		if (stride == 2)
		{
			var i : Int = (parCount << 1) - 1;
			while ( i > 0)
			{
				index[i] = index[i >> 1];
				i--;
			}
		}
	}
	
	private function deltaModuloDecode(enabled : Bool, index : Vector<Int>, indexPrev : Vector<Int>,
			time : Bool, parCount : Int, stride : Int, andModulo : Int)
	{		
		if (enabled)
		{
			if (!time)
			{
				index[0] &= andModulo;
				for (i in 1...parCount)
				{
					index[i] = index[i-1]+index[i];
					index[i] &= andModulo;
				}
			}
			else
			{
				for (i in 0...parCount)
				{
					index[i] = indexPrev[i*stride]+index[i];
					index[i] &= andModulo;
				}
			}
		}
		else
		{
			for (i in 0...parCount)
			{
				index[i] = 0;
			}
		}

		//coarse
		if (stride == 2)
		{
			index[0] = 0;
			var i : Int = (parCount << 1) - 1;
			while ( i > 0)
			{
				index[i] = index[i >> 1];
				i--;
			}
		}
	}
	
	private function map20IndexTo34(index : Vector<Int>, bins : Int)
	{
		index[0] = index[0];
		index[1] = IntDivision.intDiv((index[0]+index[1]), 2);
		index[2] = index[1];
		index[3] = index[2];
		index[4] = IntDivision.intDiv((index[2]+index[3]), 2);
		index[5] = index[3];
		index[6] = index[4];
		index[7] = index[4];
		index[8] = index[5];
		index[9] = index[5];
		index[10] = index[6];
		index[11] = index[7];
		index[12] = index[8];
		index[13] = index[8];
		index[14] = index[9];
		index[15] = index[9];
		index[16] = index[10];

		if (bins == 34)
		{
			index[17] = index[11];
			index[18] = index[12];
			index[19] = index[13];
			index[20] = index[14];
			index[21] = index[14];
			index[22] = index[15];
			index[23] = index[15];
			index[24] = index[16];
			index[25] = index[16];
			index[26] = index[17];
			index[27] = index[17];
			index[28] = index[18];
			index[29] = index[18];
			index[30] = index[18];
			index[31] = index[18];
			index[32] = index[19];
			index[33] = index[19];
		}
	}
	
	//============= decorrelation =============
	//decorrelates the mono signal using an allpass filter
	private function decorrelate(leftQMF : Vector<Vector<Vector<Float>>>,
								rightQMF : Vector<Vector<Vector<Float>>>,
								leftHybrid : Vector<Vector<Vector<Float>>>,
								rightHybrid : Vector<Vector<Vector<Float>>>)
	{
		//chose hybrid filterbank: 20 or 34 band case
		var phiFractSubQMF : Array<Array<Float>> = use34 ? PSTables.PHI_FRACT_SUBQMF34 : PSTables.PHI_FRACT_SUBQMF20;
		var qFractAllpassSubQMF : Array<Array<Array<Float>>> = use34 ? PSTables.Q_FRACT_ALLPASS_SUBQMF34 : PSTables.Q_FRACT_ALLPASS_SUBQMF20;

		//step 1: calculate the energy in each parameter band
		var p : Vector<Vector<Int>> = calculateEnergy(leftQMF, leftHybrid);

		//step 2: calculate transient reduction ratio for each parameter band
		var gTransientRatio : Vector<Vector<Float>> = calculateReductionRatio(p);

		//step 3: apply stereo decorrelation filter to the signal
		var gDecaySlope : Float;
		var gDecaySlopeFilt : Vector<Float> = new Vector<Float>(PSConstants.NO_ALLPASS_LINKS);
		var tmp0 : Vector<Float> = new Vector<Float>(2);
		var tmp1 : Vector<Float> = new Vector<Float>(2);
		var tmp2 : Vector<Float> = new Vector<Float>(2);
		var saved : Vector<Float> = new Vector<Float>(2);
		var phiFract : Vector<Float> = new Vector<Float>(2);
		var qFractAllpass : Vector<Float> = new Vector<Float>(2);
		var phiFractX : Array<Array<Float>>;
		var storeX : Vector<Vector<Vector<Float>>>;
		var delayX : Vector<Vector<Vector<Float>>>;
		var qFractAllpassX : Array<Array<Array<Float>>>;
		var inputX : Vector<Vector<Vector<Float>>>;
		var delaySerX : Vector<Vector<Vector<Vector<Float>>>>;
		var tempDelay : Int = 0;
		var tempDelaySer : Vector<Int> = new Vector<Int>(PSConstants.NO_ALLPASS_LINKS);
		var sb : Int;
		var maxSB : Int;
		var bk : Int;
		var n : Int;
		var m : Int;
		
		for (gr in 0...groups)
		{
			bk = (~PSTables.NEGATE_IPD_MASK)&mapGroupToBK[gr];

			if (gr < hybridGroups)
			{
				maxSB = groupBorder[gr]+1;
				storeX = rightHybrid;
				delaySerX = delaySubQMFSer;
				phiFractX = phiFractSubQMF;
				delayX = delaySubQMF;
				qFractAllpassX = qFractAllpassSubQMF;
				inputX = leftHybrid;
			}
			else
			{
				maxSB = groupBorder[gr+1];
				storeX = rightQMF;
				delaySerX = delayQMFSer;
				phiFractX = PSTables.PHI_FRACT_QMF;
				delayX = delayQMF;
				qFractAllpassX = PSTables.Q_FRACT_ALLPASS_QMF;
				inputX = leftQMF;
			}

			for (sb in groupBorder[gr]...maxSB)
			{
				if(gr<hybridGroups||sb<=decayCutoff) gDecaySlope = 1.0;
				else
				{
					var decay : Int = decayCutoff-sb;
					if(decay<=-20) gDecaySlope = 0;
					else gDecaySlope = 1.0+PSConstants.DECAY_SLOPE*decay;
				}

				//calculate gDecaySlopeFilt for every m multiplied by FILTER_A[m]
				for(m in 0...PSConstants.NO_ALLPASS_LINKS)
				{
					gDecaySlopeFilt[m] = gDecaySlope*PSTables.FILTER_A[m];
				}

				//set delay indices
				tempDelay = savedDelay;
				for (n in 0...PSConstants.NO_ALLPASS_LINKS)
				{
					tempDelaySer[n] = delayBufIndexSer[n];
				}

				for (n in borderPosition[0]...borderPosition[envCount])
				{
					if (sb > PSConstants.NR_ALLPASS_BANDS && gr >= hybridGroups)
					{
						tmp0[0] = delayQMF[delayBufIndexDelay[sb]][sb][0];
						tmp0[1] = delayQMF[delayBufIndexDelay[sb]][sb][1];
						saved[0] = tmp0[0];
						saved[1] = tmp0[1];
						delayQMF[delayBufIndexDelay[sb]][sb][0] = inputX[n][sb][0];
						delayQMF[delayBufIndexDelay[sb]][sb][1] = inputX[n][sb][1];
					}
					else
					{
						//select data from the subbands
						tmp1[0] = delayX[tempDelay][sb][0];
						tmp1[1] = delayX[tempDelay][sb][1];
						delayX[tempDelay][sb][0] = inputX[n][sb][0];
						delayX[tempDelay][sb][1] = inputX[n][sb][1];
						phiFract[0] = phiFractX[sb][0];
						phiFract[1] = phiFractX[sb][1];

						//z^(-2) * Phi_Fract[k]
						tmp0[0] = (tmp1[0]*phiFract[0])+(tmp1[1]*phiFract[1]);
						tmp0[1] = (tmp1[1]*phiFract[0])-(tmp1[0]*phiFract[1]);

						saved[0] = tmp0[0];
						saved[1] = tmp0[1];
						for (m in 0...PSConstants.NO_ALLPASS_LINKS)
						{
							//select data from the subbands
							tmp1[0] = delaySerX[m][tempDelaySer[m]][sb][0];
							tmp1[1] = delaySerX[m][tempDelaySer[m]][sb][1];
							qFractAllpass[0] = qFractAllpassX[sb][m][0];
							qFractAllpass[1] = qFractAllpassX[sb][m][1];

							//delay by a fraction:  z^(-d(m)) * qFractAllpass[k,m]
							tmp0[0] = (tmp1[0]*qFractAllpass[0])+(tmp1[1]*qFractAllpass[1]);
							tmp0[1] = (tmp1[1]*qFractAllpass[0])-(tmp1[0]*qFractAllpass[1]);

							//-a(m) * gDecaySlope[k]
							tmp0[0] += -(gDecaySlopeFilt[m]*saved[0]);
							tmp0[1] += -(gDecaySlopeFilt[m]*saved[1]);

							//-a(m) * gDecaySlope[k] * qFractAllpass[k,m] * z^(-d(m))
							tmp2[0] = saved[0]+(gDecaySlopeFilt[m]*tmp0[0]);
							tmp2[1] = saved[1]+(gDecaySlopeFilt[m]*tmp0[1]);

							//store sample to delaySubQMFSer or delayQMFSer
							delaySerX[m][tempDelaySer[m]][sb][0] = tmp2[0];
							delaySerX[m][tempDelaySer[m]][sb][1] = tmp2[1];

							//store for next iteration (or as output value if last iteration)
							saved[0] = tmp0[0];
							saved[1] = tmp0[1];
						}
					}

					//duck if a past transient is found
					saved[0] *= gTransientRatio[n][bk];
					saved[1] *= gTransientRatio[n][bk];

					//store to rightHybrid or rightQMF
					storeX[n][sb][0] = saved[0];
					storeX[n][sb][1] = saved[1];

					//update delay buffer index
					tempDelay++;
					if(tempDelay>=2) tempDelay = 0;

					//update delay indices
					if(sb>PSConstants.NR_ALLPASS_BANDS&&gr>=hybridGroups) {
						delayBufIndexDelay[sb]++;
						if(delayBufIndexDelay[sb]>=delayD[sb]) delayBufIndexDelay[sb] = 0;
					}

					for (m in 0...PSConstants.NO_ALLPASS_LINKS)
					{
						tempDelaySer[m]++;
						if(tempDelaySer[m]>=sampleDelaySerCount[m]) tempDelaySer[m] = 0;
					}
				}
			}
		}

		//update indices
		savedDelay = tempDelay;
		for (m in 0...PSConstants.NO_ALLPASS_LINKS)
		{
			delayBufIndexSer[m] = tempDelaySer[m];
		}
	}
	
	private function calculateEnergy(leftQMF : Vector<Vector<Vector<Float>>>,
									leftHybrid : Vector<Vector<Vector<Float>>>) : Vector<Vector<Int>>
	{
		//final int[][] out = new int[32][34];
		var out : Vector<Vector<Int>> = VectorTools.newMatrixVectorI(32, 34);
		var tmp : Vector<Float> = new Vector<Float>(2);

		var input : Vector<Vector<Vector<Float>>>;
		var bk : Int;
		var sb : Int;
		var maxSB : Int;
		var n : Int;
		for (gr in 0...groups)
		{
			//select the parameter index b(k) to which this group belongs
			bk = (~PSTables.NEGATE_IPD_MASK)&mapGroupToBK[gr];

			//select the upper subband border for this group
			if (gr < hybridGroups)
			{
				maxSB = groupBorder[gr]+1;
				input = leftHybrid;
			}
			else {
				maxSB = groupBorder[gr+1];
				input = leftQMF;
			}

			for (sb in groupBorder[gr]...maxSB)
			{
				for (n in borderPosition[0]...borderPosition[envCount])
				{
					//input from hybrid subbands or QMF subbands
					tmp[0] = input[n][sb][0];
					tmp[1] = input[n][sb][1];
					//accumulate energy
					out[n][bk] += Std.int((tmp[0]*tmp[0])+(tmp[1]*tmp[1]));
				}
			}
		}

		return out;
	}
	
	private function calculateReductionRatio(p : Vector<Vector<Int>>) : Vector<Vector<Float>>
	{
		//final float[][] out = new float[32][34];
		var out : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(32, 34);

		var smoothPeakDecayDiffEnergy : Float;
		var energy : Float;
		
		for (bk in 0...parBands)
		{
			for (n in borderPosition[0]...borderPosition[envCount])
			{
				peakDecayEnergy[bk] = (peakDecayEnergy[bk]*PSConstants.ALPHA_DECAY);
				if(peakDecayEnergy[bk]<p[n][bk]) peakDecayEnergy[bk] = p[n][bk];

				//apply smoothing filter to peak decay energy
				smoothPeakDecayDiffEnergy = smoothPeakDecayDiffEnergyPrev[bk];
				smoothPeakDecayDiffEnergy += ((peakDecayEnergy[bk]-p[n][bk]-smoothPeakDecayDiffEnergyPrev[bk])*PSConstants.ALPHA_SMOOTH);
				smoothPeakDecayDiffEnergyPrev[bk] = smoothPeakDecayDiffEnergy;

				//apply smoothing filter to energy
				energy = pPrev[bk];
				energy += (p[n][bk]-pPrev[bk])*PSConstants.ALPHA_SMOOTH;
				pPrev[bk] = energy;

				//calculate transient ratio
				if((smoothPeakDecayDiffEnergy*PSConstants.REDUCTION_RATIO_GAMMA)<=energy) out[n][bk] = 1.0;
				else out[n][bk] = energy/(smoothPeakDecayDiffEnergy*PSConstants.REDUCTION_RATIO_GAMMA);
			}
		}

		return out;
	}
	
	//============= mixing/phase =============
	private function mixPhase(leftQMF : Vector<Vector<Vector<Float>>>,
							rightQMF : Vector<Vector<Vector<Float>>>,
							leftHybrid : Vector<Vector<Vector<Float>>>,
							rightHybrid : Vector<Vector<Vector<Float>>>)
	{
		var h1 : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(2, 2);
		var h2 : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(2, 2);
		var H1 : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(2, 2);
		var H2 : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(2, 2);
		var deltaH11 : Vector<Float> = new Vector<Float>(2);
		var deltaH12 : Vector<Float> = new Vector<Float>(2);
		var deltaH21 : Vector<Float> = new Vector<Float>(2);
		var deltaH22 : Vector<Float> = new Vector<Float>(2);
		var tempLeft : Vector<Float> = new Vector<Float>(2);
		var tempRight : Vector<Float> = new Vector<Float>(2);

		var curIpdopdPars : Int = (ipdMode==0||ipdMode==3) ? 11 : ipdopdPars;

		//int n, sb, maxsb, env, bk;
		var bk : Int;
		var maxsb : Int;
		var L : Float;
		for (gr in 0...groups)
		{
			bk = (~PSTables.NEGATE_IPD_MASK)&mapGroupToBK[gr];

			//use one channel per group in the subqmf domain
			maxsb = (gr<hybridGroups) ? groupBorder[gr]+1 : groupBorder[gr+1];

			for (env in 0...envCount)
			{
				//mixing
				if(iccMode<3) applyMixingA(env, bk, h1, h2);
				else applyMixingB(env, bk, h1, h2);

				//calculate phase rotation parameters
				if((ipdopdEnabled)&&(bk<curIpdopdPars)) calculatePhaseRotation(env, bk, h1, h2);

				//length of the envelope (in time samples); 0 < L <= 32
				L = (borderPosition[env+1]-borderPosition[env]);

				//obtain final H by means of linear interpolation
				deltaH11[0] = (h1[0][0]-h11Prev[gr][0])/L;
				deltaH12[0] = (h1[1][0]-h12Prev[gr][0])/L;
				deltaH21[0] = (h2[0][0]-h21Prev[gr][0])/L;
				deltaH22[0] = (h2[1][0]-h22Prev[gr][0])/L;

				H1[0][0] = h11Prev[gr][0];
				H1[1][0] = h12Prev[gr][0];
				H2[0][0] = h21Prev[gr][0];
				H2[1][0] = h22Prev[gr][0];

				h11Prev[gr][0] = h1[0][0];
				h12Prev[gr][0] = h1[1][0];
				h21Prev[gr][0] = h2[0][0];
				h22Prev[gr][0] = h2[1][0];

				if ((ipdopdEnabled) && (bk < curIpdopdPars))
				{
					//obtain final H_xy by means of linear interpolation
					deltaH11[1] = (h1[0][1]-h11Prev[gr][1])/L;
					deltaH12[1] = (h1[1][1]-h12Prev[gr][1])/L;
					deltaH21[1] = (h2[0][1]-h21Prev[gr][1])/L;
					deltaH22[1] = (h2[1][1]-h22Prev[gr][1])/L;

					H1[0][1] = h11Prev[gr][1];
					H1[1][1] = h12Prev[gr][1];
					H2[0][1] = h21Prev[gr][1];
					H2[1][1] = h22Prev[gr][1];

					if ((PSTables.NEGATE_IPD_MASK & mapGroupToBK[gr]) != 0)
					{
						deltaH11[1] = -deltaH11[1];
						deltaH12[1] = -deltaH12[1];
						deltaH21[1] = -deltaH21[1];
						deltaH22[1] = -deltaH22[1];

						H1[0][1] = -H1[0][1];
						H1[1][1] = -H1[1][1];
						H2[0][1] = -H2[0][1];
						H2[1][1] = -H2[1][1];
					}

					h11Prev[gr][1] = h1[0][1];
					h12Prev[gr][1] = h1[1][1];
					h21Prev[gr][1] = h2[0][1];
					h22Prev[gr][1] = h2[1][1];
				}

				//apply H_xy to the current envelope band of the decorrelated subband
				for (n in borderPosition[env]...borderPosition[env + 1])
				{
					//addition finalises the interpolation over every n
					H1[0][0] += deltaH11[0];
					H1[1][0] += deltaH12[0];
					H2[0][0] += deltaH21[0];
					H2[1][0] += deltaH22[0];
					if ((ipdopdEnabled) && (bk < curIpdopdPars))
					{
						H1[0][1] += deltaH11[1];
						H1[1][1] += deltaH12[1];
						H2[0][1] += deltaH21[1];
						H2[1][1] += deltaH22[1];
					}

					//channel is an alias to the subband
					for (sb in groupBorder[gr]...maxsb)
					{						
						var inLeft = new Vector<Float>(2);
						var inRight = new Vector<Float>(2);

						/* load decorrelated samples */
						if (gr < hybridGroups)
						{
							inLeft[0] = leftHybrid[n][sb][0];
							inLeft[1] = leftHybrid[n][sb][1];
							inRight[0] = rightHybrid[n][sb][0];
							inRight[1] = rightHybrid[n][sb][1];
						}
						else
						{
							inLeft[0] = leftQMF[n][sb][0];
							inLeft[1] = leftQMF[n][sb][1];
							inRight[0] = rightQMF[n][sb][0];
							inRight[1] = rightQMF[n][sb][1];
						}

						//apply mixing
						tempLeft[0] = (H1[0][0]*inLeft[0])+(H2[0][0]*inRight[0]);
						tempLeft[1] = (H1[0][0]*inLeft[1])+(H2[0][0]*inRight[1]);
						tempRight[0] = (H1[1][0]*inLeft[0])+(H2[1][0]*inRight[0]);
						tempRight[1] = (H1[1][0]*inLeft[1])+(H2[1][0]*inRight[1]);

						if ((ipdopdEnabled) && (bk < curIpdopdPars))
						{
							//apply rotation
							tempLeft[0] -= (H1[0][1]*inLeft[1])+(H2[0][1]*inRight[1]);
							tempLeft[1] += (H1[0][1]*inLeft[0])+(H2[0][1]*inRight[0]);
							tempRight[0] -= (H1[1][1]*inLeft[1])+(H2[1][1]*inRight[1]);
							tempRight[1] += (H1[1][1]*inLeft[0])+(H2[1][1]*inRight[0]);
						}

						//store final samples
						if (gr < hybridGroups)
						{
							leftHybrid[n][sb][0] = tempLeft[0];
							leftHybrid[n][sb][1] = tempLeft[1];
							rightHybrid[n][sb][0] = tempRight[0];
							rightHybrid[n][sb][1] = tempRight[1];
						}
						else
						{
							leftQMF[n][sb][0] = tempLeft[0];
							leftQMF[n][sb][1] = tempLeft[1];
							rightQMF[n][sb][0] = tempRight[0];
							rightQMF[n][sb][1] = tempRight[1];
						}
					}
				}

				//shift phase smoother's circular buffer index
				phaseHist++;
				if(phaseHist==2) phaseHist = 0;
			}
		}
	}
	
	//type 'A' mixing
	private function applyMixingA(env : Int, bk : Int, out1 : Vector<Vector<Float>>, out2 : Vector<Vector<Float>>)
	{
		//calculate the scalefactors c1 and c2 from the intensity differences
		var c1 : Float = sfIID[iidSteps+iidIndex[env][bk]];
		var c2 : Float = sfIID[iidSteps-iidIndex[env][bk]];

		// TODO: Fix this hack
		if (iccIndex[env][bk] < 0)
			iccIndex[env][bk] = 0;
		
		//calculate alpha and beta using the ICC parameters
		var cosa : Float = PSTables.COS_ALPHAS[iccIndex[env][bk]];
		var sina : Float = PSTables.SIN_ALPHAS[iccIndex[env][bk]];

		var cosb : Float;
		var sinb : Float;
		if (iidMode >= 3)
		{
			if (iidIndex[env][bk] < 0)
			{
				cosb = PSTables.COS_BETAS_FINE[-iidIndex[env][bk]][iccIndex[env][bk]];
				sinb = -PSTables.SIN_BETAS_FINE[-iidIndex[env][bk]][iccIndex[env][bk]];
			}
			else
			{
				cosb = PSTables.COS_BETAS_FINE[iidIndex[env][bk]][iccIndex[env][bk]];
				sinb = PSTables.SIN_BETAS_FINE[iidIndex[env][bk]][iccIndex[env][bk]];
			}
		}
		else {
			if (iidIndex[env][bk] < 0)
			{
				cosb = PSTables.COS_BETAS_NORMAL[-iidIndex[env][bk]][iccIndex[env][bk]];
				sinb = -PSTables.SIN_BETAS_NORMAL[-iidIndex[env][bk]][iccIndex[env][bk]];
			}
			else
			{
				cosb = PSTables.COS_BETAS_NORMAL[iidIndex[env][bk]][iccIndex[env][bk]];
				sinb = PSTables.SIN_BETAS_NORMAL[iidIndex[env][bk]][iccIndex[env][bk]];
			}
		}

		var ab1 : Float = cosb*cosa;
		var ab2 : Float = sinb*sina;
		var ab3 : Float = sinb*cosa;
		var ab4 : Float = cosb*sina;

		out1[0][0] = c2*(ab1-ab2);
		out1[1][0] = c1*(ab1+ab2);
		out2[0][0] = c2*(ab3+ab4);
		out2[1][0] = c1*(ab3-ab4);
	}

	//type 'B' mixing
	private function applyMixingB(env : Int, bk : Int, out1 : Vector<Vector<Float>>, out2 : Vector<Vector<Float>>)
	{
		var cosa : Float;
		var sina : Float;
		var cosg : Float;
		var sing : Float;
		var absIID : Int = IntMath.abs(iidIndex[env][bk]);
		if (iidMode >= 3)
		{
			cosa = PSTables.SINCOS_ALPHAS_B_FINE[iidSteps+iidIndex[env][bk]][iccIndex[env][bk]];
			sina = PSTables.SINCOS_ALPHAS_B_FINE[30-(iidSteps+iidIndex[env][bk])][iccIndex[env][bk]];
			cosg = PSTables.COS_GAMMAS_FINE[absIID][iccIndex[env][bk]];
			sing = PSTables.SIN_GAMMAS_FINE[absIID][iccIndex[env][bk]];
		}
		else
		{
			cosa = PSTables.SINCOS_ALPHAS_B_NORMAL[iidSteps+iidIndex[env][bk]][iccIndex[env][bk]];
			sina = PSTables.SINCOS_ALPHAS_B_NORMAL[14-(iidSteps+iidIndex[env][bk])][iccIndex[env][bk]];
			cosg = PSTables.COS_GAMMAS_NORMAL[absIID][iccIndex[env][bk]];
			sing = PSTables.SIN_GAMMAS_NORMAL[absIID][iccIndex[env][bk]];
		}

		out1[0][0] = PSConstants.SQRT2*(cosa*cosg);
		out1[1][0] = PSConstants.SQRT2*(sina*cosg);
		out2[0][0] = PSConstants.SQRT2*(-cosa*sing);
		out2[1][0] = PSConstants.SQRT2*(sina*sing);
	}
	
	private function calculatePhaseRotation(env : Int, bk : Int, out1 : Vector<Vector<Float>>, out2 : Vector<Vector<Float>>)
	{
		var tempLeft : Vector<Float> = new Vector<Float>(2);
		var tempRight : Vector<Float> = new Vector<Float>(2);
		var phaseLeft : Vector<Float> = new Vector<Float>(2);
		var phaseRight : Vector<Float> = new Vector<Float>(2);
		var i : Int = phaseHist; //ringbuffer index

		//previous value
		tempLeft[0] = ipdPrev[bk][i][0]*0.25;
		tempLeft[1] = ipdPrev[bk][i][1]*0.25;
		tempRight[0] = opdPrev[bk][i][0]*0.25;
		tempRight[1] = opdPrev[bk][i][1]*0.25;

		//save current value
		ipdPrev[bk][i][0] = PSTables.IPDOPD_COS_TAB[IntMath.abs(ipdIndex[env][bk])];
		ipdPrev[bk][i][1] = PSTables.IPDOPD_SIN_TAB[IntMath.abs(ipdIndex[env][bk])];
		opdPrev[bk][i][0] = PSTables.IPDOPD_COS_TAB[IntMath.abs(opdIndex[env][bk])];
		opdPrev[bk][i][1] = PSTables.IPDOPD_SIN_TAB[IntMath.abs(opdIndex[env][bk])];

		//add current value
		tempLeft[0] += ipdPrev[bk][i][0];
		tempLeft[1] += ipdPrev[bk][i][1];
		tempRight[0] += opdPrev[bk][i][0];
		tempRight[1] += opdPrev[bk][i][1];

		if(i==0) i = 2;
		i--;

		//get value before previous
		tempLeft[0] += ipdPrev[bk][i][0]*0.5;
		tempLeft[1] += ipdPrev[bk][i][1]*0.5;
		tempRight[0] += opdPrev[bk][i][0]*0.5;
		tempRight[1] += opdPrev[bk][i][1]*0.5;
		
		var xy : Float = Math.sqrt(tempRight[0]*tempRight[0]+tempRight[1]*tempRight[1]);
		var pq : Float = Math.sqrt(tempLeft[0]*tempLeft[0]+tempLeft[1]*tempLeft[1]);

		if (xy != 0)
		{
			phaseLeft[0] = tempRight[0]/xy;
			phaseLeft[1] = tempRight[1]/xy;
		}
		else
		{
			phaseLeft[0] = 0;
			phaseLeft[1] = 0;
		}

		var xypq : Float = xy*pq;
		if (xypq != 0)
		{
			var tmp1 : Float = (tempRight[0]*tempLeft[0])+(tempRight[1]*tempLeft[1]);
			var tmp2 : Float = (tempRight[1]*tempLeft[0])-(tempRight[0]*tempLeft[1]);
			phaseRight[0] = tmp1/xypq;
			phaseRight[1] = tmp2/xypq;
		}
		else
		{
			phaseRight[0] = 0;
			phaseRight[1] = 0;
		}

		out1[0][1] = out1[0][0]*phaseLeft[1];
		out1[1][1] = out1[1][0]*phaseRight[1];
		out2[0][1] = out2[0][0]*phaseLeft[1];
		out2[1][1] = out2[1][0]*phaseRight[1];
		out1[0][0] = out1[0][0]*phaseLeft[0];
		out1[1][0] = out1[1][0]*phaseRight[0];
		out2[0][0] = out2[0][0]*phaseLeft[0];
		out2[1][0] = out2[1][0]*phaseRight[0];
	}
	
}