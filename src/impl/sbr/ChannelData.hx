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
import impl.IntMath;
import impl.VectorTools;

class ChannelData 
{
	
	public static var LOG2TABLE : Array<Int> = [0, 0, 1, 2, 2, 3, 3, 3, 3, 4];
	//read
	public var frameClass : Int;
	public var pointer : Int;
	public var addHarmonicFlag : Bool;
	public var addHarmonicFlagPrev : Bool;
	public var addHarmonic : Vector<Bool>;
	public var addHarmonicPrev : Vector<Bool>;
	public var relBord : Vector<Int>;
	public var relBord0 : Vector<Int>;
	public var relBord1 : Vector<Int>;
	public var rel0 : Int;
	public var rel1 : Int;
	public var dfEnv : Vector<Bool>;
	public var dfNoise : Vector<Bool>;
	public var invfMode : Vector<Int>;
	public var invfModePrev : Vector<Int>;
	//calculated
	public var ampRes : Bool;
	public var t_E : Vector<Int>; public var tEtmp : Vector<Int>; public var t_Q : Vector<Int>; //envelope/noise time border vectors
	public var L_E : Int; public var L_E_prev : Int; public var L_Q : Int; //length of t_E/t_Q
	public var f : Vector<Bool>;
	public var fPrev : Bool;
	public var gTempPrev : Vector<Vector<Float>>;
	public var qTempPrev : Vector<Vector<Float>>;
	public var gqIndex : Int;
	public var E : Vector<Vector<Int>>;
	public var E_prev : Vector<Int>;
	public var E_orig : Vector<Vector<Float>>;
	public var E_curr : Vector<Vector<Float>>;
	public var Q : Vector<Vector<Int>>;
	public var Q_prev : Vector<Int>;
	public var Q_div : Vector<Vector<Float>>;
	public var Q_div2 : Vector<Vector<Float>>;
	//
	public var absBordLead : Int;
	public var absBordTrail : Int;
	public var prevEnvIsShort : Int;
	public var l_A : Int;
	public var l_A_prev : Int;
	public var Xsbr : Vector<Vector<Vector<Float>>>;
	public var bwVector : Vector<Float>;
	public var bwVectorPrev : Vector<Float>;
	public var indexNoisePrev : Int;
	public var psiIsPrev : Int;
	public var bwArray : Vector<Float>;
	public var bwArrayPrev : Vector<Float>;
	
	public function new()
	{
		addHarmonic = new Vector<Bool>(64);
		addHarmonicPrev = new Vector<Bool>(64);
		/*
		for ( i in 0...64 )
			addHarmonic[i] = addHarmonicPrev[i] = false;
		*/
		relBord = new Vector<Int>(9);
		relBord0 = new Vector<Int>(9);
		relBord1 = new Vector<Int>(9);
		dfEnv = new Vector<Bool>(9);
		dfNoise = new Vector<Bool>(3);
		invfMode = new Vector<Int>(SBRConstants.MAX_L_E);
		invfModePrev = new Vector<Int>(SBRConstants.MAX_L_E);
		t_E = new Vector<Int>(SBRConstants.MAX_L_E+1);
		tEtmp = new Vector<Int>(6);
		t_Q = new Vector<Int>(3);
		f = new Vector<Bool>(SBRConstants.MAX_L_E + 1);
		//gTempPrev = new float[5][64];
		gTempPrev = VectorTools.newMatrixVectorF(5, 64);
		//qTempPrev = new float[5][64];
		qTempPrev = VectorTools.newMatrixVectorF(5, 64);
		//E = new int[64][MAX_L_E];
		E = VectorTools.newMatrixVectorI(64, SBRConstants.MAX_L_E);
		E_prev = new Vector<Int>(64);
		//E_orig = new float[64][MAX_L_E];
		E_orig = VectorTools.newMatrixVectorF(64, SBRConstants.MAX_L_E);
		//E_curr = new float[64][MAX_L_E];
		E_curr = VectorTools.newMatrixVectorF(64, SBRConstants.MAX_L_E);
		//Q = new int[64][2];
		Q = VectorTools.newMatrixVectorI(64, 2);
		Q_prev = new Vector<Int>(64);
		//Q_div = new float[64][2];
		Q_div = VectorTools.newMatrixVectorF(64, 2);
		//Q_div2 = new float[64][2];
		Q_div2 = VectorTools.newMatrixVectorF(64, 2);
		bwArray = new Vector<Float>(64);
		bwArrayPrev = new Vector<Float>(64);
		//Xsbr = new float[MAX_NTSRHFG][64][2];
		Xsbr = VectorTools.new3DMatrixVectorF(SBRConstants.MAX_NTSRHFG, 64, 2);

		gqIndex = 0;
	}

	/* ================= decoding ================= */
	public function decodeGrid(input : BitStream)
	{
		var savedL_E : Int = L_E;
		var savedL_Q : Int = L_Q;
		var savedFrameClass : Int = frameClass;

		var envCount : Int = 0;
		//int i, x, absBord0, absBord1;
		var absBord0 : Int;
		var absBord1 : Int;
		var x : Int;
		switch(frameClass = input.readBits(2))
		{
			case SBRConstants.FIXFIX:
			{
				x = input.readBits(2);
				envCount = IntMath.min(1<<x, 5);
				var b : Bool = input.readBool();
				for (i in 0...envCount)
				{
					f[i] = b;
				}

				absBordLead = 0;
				absBordTrail = SBRConstants.TIME_SLOTS;
				//n_rel_lead = bs_num_env-1;
				//n_rel_trail = 0;
			}

			case SBRConstants.FIXVAR:
			{
				absBord0 = input.readBits(2)+SBRConstants.TIME_SLOTS;
				envCount = input.readBits(2)+1;
				for (i in 0...(envCount - 1))
				{
					relBord[i] = 2*input.readBits(2)+2;
				}
				pointer = input.readBits(LOG2TABLE[envCount+1]);
				for (i in 0...envCount)
				{
					f[envCount-i-1] = input.readBool();
				}
				absBordLead = 0;
				absBordTrail = absBord0;
				//n_rel_lead = 0;
				//n_rel_trail = bs_num_env-1;
			}

			case SBRConstants.VARFIX:
			{
				absBord0 = input.readBits(2);
				envCount = input.readBits(2)+1;

				for (i in 0...(envCount - 1))
				{
					relBord[i] = 2*input.readBits(2)+2;
				}
				x = LOG2TABLE[envCount+1];
				pointer = input.readBits(x);

				for (i in 0...envCount)
				{
					f[i] = input.readBool();
				}

				absBordLead = absBord0;
				absBordTrail = SBRConstants.TIME_SLOTS;
				//n_rel_lead = bs_num_env-1;
				//n_rel_trail = 0;
			}

			case SBRConstants.VARVAR:
			{
				absBord0 = input.readBits(2);
				absBord1 = input.readBits(2)+SBRConstants.TIME_SLOTS;
				rel0 = input.readBits(2);
				rel1 = input.readBits(2);
				envCount = IntMath.min(5, rel0+rel1+1);
				for (i in 0...rel0)
				{
					relBord0[i] = 2*input.readBits(2)+2;
				}
				for (i in 0...rel1)
				{
					relBord1[i] = 2*input.readBits(2)+2;
				}
				x = LOG2TABLE[rel0+rel1+2];
				pointer = input.readBits(x);
				for (i in 0...envCount)
				{
					f[i] = input.readBool();
				}
				absBordLead = absBord0;
				absBordTrail = absBord1;
				//n_rel_lead = bs_num_rel_0;
				//n_rel_trail = bs_num_rel_1;
			}
		}

		if(frameClass==SBRConstants.VARVAR) L_E = IntMath.min(envCount, 5);
		else L_E = IntMath.min(envCount, 4);

		if(L_E<=0) throw("L_E out of range: "+L_E);

		if(L_E>1) L_Q = 2;
		else L_Q = 1;

		if (!envelopeTimeBorderVector())
		{
			//Constants.LOGGER.warning("envelopeTimeBorderVector failed");
			frameClass = savedFrameClass;
			L_E = savedL_E;
			L_Q = savedL_Q;
		}
		noiseFloorTimeBorderVector();
	}

	public function copyGrid(cd : ChannelData)
	{
		frameClass = cd.frameClass;
		L_E = cd.L_E;
		L_Q = cd.L_Q;
		pointer = cd.pointer;

		//System.arraycopy(cd.t_E, 0, t_E, 0, L_E+1);
		VectorTools.vectorcopyI(cd.t_E, 0, t_E, 0, L_E + 1);
		//System.arraycopy(cd.f, 0, f, 0, L_E+1);
		VectorTools.vectorcopy(cd.f, 0, f, 0, L_E+1);
		//System.arraycopy(cd.t_Q, 0, t_Q, 0, L_Q+1);
		VectorTools.vectorcopyI(cd.t_Q, 0, t_Q, 0, L_Q+1);
	}
	
	public function decodeDTDF(input : BitStream)
	{
		for (i in 0...L_E)
		{
			dfEnv[i] = input.readBool();
		}

		for (i in 0...L_Q)
		{
			dfNoise[i] = input.readBool();
		}
	}

	public function decodeInvfMode(input : BitStream, len : Int)
	{
		for (i in 0...len)
		{
			invfMode[i] = input.readBits(2);
		}
	}

	public function copyInvfMode(cd : ChannelData, len : Int)
	{
		//System.arraycopy(cd.invfMode, 0, invfMode, 0, len);
		VectorTools.vectorcopyI(cd.invfMode, 0, invfMode, 0, len);
	}

	public function decodeSinusoidalCoding(input : BitStream, len : Int)
	{
		if (addHarmonicFlag = input.readBool())
		{
			for (i in 0...len)
			{
				addHarmonic[i] = input.readBool();
			}
		}
	}

	/* ================= huffman ================= */
	public function decodeEnvelope(input : BitStream, sbr : SBR, ch : Int)
	{
		ampRes = ((L_E==1)&&(frameClass==SBRConstants.FIXFIX)) ? false : sbr.ampRes;
		var bits : Int = 7-((sbr.coupling&&(ch==1)) ? 1 : 0)-(ampRes ? 1 : 0);

		var delta : Int;
		var huffT : Array<Array<Int>>;
		var huffF : Array<Array<Int>>;
		if (sbr.coupling && (ch == 1))
		{
			delta = 1;
			if (ampRes)
			{
				huffT = HuffmanTables.T_HUFFMAN_ENV_BAL_3_0DB;
				huffF = HuffmanTables.F_HUFFMAN_ENV_BAL_3_0DB;
			}
			else
			{
				huffT = HuffmanTables.T_HUFFMAN_ENV_BAL_1_5DB;
				huffF = HuffmanTables.F_HUFFMAN_ENV_BAL_1_5DB;
			}
		}
		else
		{
			delta = 0;
			if (ampRes)
			{
				huffT = HuffmanTables.T_HUFFMAN_ENV_3_0DB;
				huffF = HuffmanTables.F_HUFFMAN_ENV_3_0DB;
			}
			else
			{
				huffT = HuffmanTables.T_HUFFMAN_ENV_1_5DB;
				huffF = HuffmanTables.F_HUFFMAN_ENV_1_5DB;
			}
		}

		var j : Int;
		for (i in 0...L_E)
		{
			if (!dfEnv[i])
			{
				E[0][i] = input.readBits(bits) << delta;
				j = 1;
				while(j<sbr.n[f[i] ? 1 : 0])
				{
					E[j][i] = decodeHuffman(input, huffF) << delta;
					j++;
				}
			}
			else
			{
				j = 0;
				while (j < sbr.n[f[i] ? 1 : 0])
				{
					E[j][i] = decodeHuffman(input, huffT) << delta;
					j++;
				}
			}
		}

		extractEnvelopeData(sbr);
	}

	public function decodeNoise(input : BitStream, sbr : SBR, ch : Int)
	{
		var delta : Int;
		var huffT : Array<Array<Int>>;
		var huffF : Array<Array<Int>>;
		if (sbr.coupling && (ch == 1))
		{
			delta = 1;
			huffT = HuffmanTables.T_HUFFMAN_NOISE_BAL_3_0DB;
			huffF = HuffmanTables.F_HUFFMAN_ENV_BAL_3_0DB;
		}
		else
		{
			delta = 0;
			huffT = HuffmanTables.T_HUFFMAN_NOISE_3_0DB;
			huffF = HuffmanTables.F_HUFFMAN_ENV_3_0DB;
		}

		var len : Int = sbr.N_Q;		
		for (i in 0...L_Q)
		{
			if (!dfNoise[i])
			{
				Q[0][i] = input.readBits(5)<<delta;
				for (j in 1...len)
				{
					Q[j][i] = decodeHuffman(input, huffF)<<delta;
				}
			}
			else
			{
				for (j in 0...len)
				{
					Q[j][i] = decodeHuffman(input, huffT)<<delta;
				}
			}
		}
		extractNoiseFloorData(sbr);
	}

	private function decodeHuffman(input : BitStream, table : Array<Array<Int>>) : Int
	{
		var index : Int = 0;
		var bit : Int;
		while (index >= 0)
		{
			bit = input.readBit();
			index = table[index][bit];
		}
		return index+HuffmanTables.HUFFMAN_OFFSET;
	}

	/* ================= computation ================= */
	//constructs new time border vector
	private function envelopeTimeBorderVector()
	{
		for (i in 0...6)
		{
			tEtmp[i] = 0;
		}

		tEtmp[0] = SBRConstants.RATE*absBordLead;
		tEtmp[L_E] = SBRConstants.RATE*absBordTrail;

		//int i, x, border;
		var border : Int;
		var x : Int;
		switch(frameClass)
		{
			case SBRConstants.FIXFIX:
			{
				switch(L_E)
				{
					case 4:
					{
						var temp : Int = Std.int(SBRConstants.TIME_SLOTS/4.0);
						tEtmp[3] = SBRConstants.RATE*3*temp;
						tEtmp[2] = SBRConstants.RATE*2*temp;
						tEtmp[1] = SBRConstants.RATE*temp;
					}
					case 2:
					{
						tEtmp[1] = SBRConstants.RATE*Std.int(SBRConstants.TIME_SLOTS/2);
					}
					/*
					default:
					{}
					*/
				}
			}
			case SBRConstants.FIXVAR:
			{
				if (L_E > 1)
				{
					x = L_E;
					border = absBordTrail;
					for (i in 0...(L_E-1))
					{
						if(border<relBord[i]) return false;
						border -= relBord[i];
						tEtmp[--x] = SBRConstants.RATE*border;
					}
				}
			}
			case SBRConstants.VARFIX:
			{
				if (L_E > 1)
				{
					x = 1;
					border = absBordLead;
					for (i in 0...(L_E-1))
					{
						border += relBord[i];
						if (SBRConstants.RATE * border + SBRConstants.T_HFADJ > SBRConstants.TIME_SLOTS_RATE + SBRConstants.T_HFGEN)
							return false;
						tEtmp[x++] = SBRConstants.RATE*border;
					}
				}
			}
			case SBRConstants.VARVAR:
			{
				if(rel0>0) {
					x = 1;
					border = absBordLead;
					for (i in 0...rel0)
					{
						border += relBord0[i];
						if (SBRConstants.RATE * border + SBRConstants.T_HFADJ > SBRConstants.TIME_SLOTS_RATE + SBRConstants.T_HFGEN)
							return false;
						tEtmp[x++] = SBRConstants.RATE*border;
					}
				}
				if (rel1 > 0)
				{
					x = L_E;
					border = absBordTrail;
					for (i in 0...rel1)
					{
						if(border<relBord1[i]) return false;
						border -= relBord1[i];
						tEtmp[--x] = SBRConstants.RATE*border;
					}
				}
			}
		}

		//no error occured
		//System.arraycopy(tEtmp, 0, t_E, 0, 6);
		VectorTools.vectorcopyI(tEtmp, 0, t_E, 0, 6);
		return true;
	}

	private function noiseFloorTimeBorderVector()
	{
		t_Q[0] = t_E[0];

		if (L_E == 1)
		{
			t_Q[1] = t_E[1];
			t_Q[2] = 0;
		}
		else
		{
			t_Q[1] = t_E[findMiddleBorder()];
			t_Q[2] = t_E[L_E];
		}
	}

	private function findMiddleBorder() : Int
	{
		var r : Int = 0;

		switch(frameClass)
		{
			case SBRConstants.FIXFIX:
			{
				r = Std.int(L_E / 2);
			}
			case SBRConstants.VARFIX:
			{
				if(pointer==0) r = 1;
				else if(pointer==1) r = L_E-1;
				else r = pointer-1;
			}
			case SBRConstants.FIXVAR, SBRConstants.VARVAR:
			{
				if(pointer>1) r = L_E+1-pointer;
				else r = L_E-1;
			}
		}

		return r>0 ? r : 0;
	}

	private function extractEnvelopeData(sbr : SBR)
	{		
		var j : Int;
		var k : Int;
		var g : Bool;
		for (i in 0...L_E)
		{
			if (!dfEnv[i])
			{
				j = 1;
				while (j < sbr.n[f[i] ? 1 : 0])
				{
					E[j][i] += E[j-1][i];
					if (E[j][i] < 0) E[j][i] = 0;
					j++;
				}

			}
			else
			{
				g = (i==0) ? fPrev : f[i-1];

				if (f[i] == g)
				{
					j = 0;
					while (j < sbr.n[f[i] ? 1 : 0])
					{
						E[j][i] += (i == 0) ? E_prev[j] : E[j][i - 1];
						j++;
					}
				}
				else if (g && !f[i])
				{
					j = 0;
					while (j < sbr.n[f[i] ? 1 : 0])
					{
						for (k in 0...sbr.N_high)
						{
							if (sbr.ftRes[SBRConstants.HI_RES][k] == sbr.ftRes[SBRConstants.LO_RES][j])
							{
								E[j][i] += (i==0) ? E_prev[k] : E[k][i-1];
							}
						}
						j++;
					}

				}
				else if (!g && f[i])
				{
					j = 0;
					while (j < sbr.n[f[i] ? 1 : 0])
					{
						for (k in 0...sbr.N_low)
						{
							if((sbr.ftRes[SBRConstants.LO_RES][k]<=sbr.ftRes[SBRConstants.HI_RES][j])
									&&(sbr.ftRes[SBRConstants.HI_RES][j] < sbr.ftRes[SBRConstants.LO_RES][k + 1]))
							{
								E[j][i] += (i==0) ? E_prev[k] : E[k][i-1];
							}
						}
						j++;
					}
				}
			}
		}
	}

	private function extractNoiseFloorData(sbr : SBR)
	{
		var len : Int = sbr.N_Q;

		//int j;
		for (i in 0...L_Q)
		{
			if (dfNoise[i])
			{
				if (i == 0)
				{
					for (j in 0...len)
					{
						Q[j][i] = Q_prev[j]+Q[j][0];
					}
				}
				else
				{
					for (j in 0...len)
					{
						Q[j][i] += Q[j][i-1];
					}
				}
			}
			else
			{
				for (j in 1...len)
				{
					Q[j][i] += Q[j-1][i];
				}
			}
		}
	}

	/* ================= processing ================== */
	public function savePreviousData()
	{
		L_E_prev = L_E;
		fPrev = f[L_E-1];

		for (i in 0...SBRConstants.MAX_M)
		{
			E_prev[i] = E[i][L_E-1];
			Q_prev[i] = Q[i][L_Q-1];
		}

		//System.arraycopy(addHarmonic, 0, addHarmonicPrev, 0, MAX_M);
		VectorTools.vectorcopyB(addHarmonic, 0, addHarmonicPrev, 0, SBRConstants.MAX_M);
		addHarmonicFlagPrev = addHarmonicFlag;

		prevEnvIsShort = (l_A==L_E) ? 0 : -1;
	}

	public function saveMatrix()
	{		
		//copy complex values
		for (i in 0...SBRConstants.T_HFGEN)
		{
			for (j in 0...64)
			{
				Xsbr[i][j][0] = Xsbr[i+SBRConstants.TIME_SLOTS_RATE][j][0];
				Xsbr[i][j][1] = Xsbr[i+SBRConstants.TIME_SLOTS_RATE][j][1];
			}
		}
		for (i in SBRConstants.T_HFGEN...SBRConstants.MAX_NTSRHFG)
		{
			for (j in 0...64)
			{
				Xsbr[i][j][0] = 0;
				Xsbr[i][j][1] = 0;
			}
		}
	}
}