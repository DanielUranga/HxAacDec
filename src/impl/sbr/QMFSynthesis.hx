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
import impl.VectorTools;

class QMFSynthesis 
{

	private static var SCALE  : Float = 1.0/64.0;
	private var filterBank : Filterbank;
	private var v : Vector<Float>;
	private var x : Vector<Vector<Float>>;
	private var tmpIn1 : Vector<Vector<Float>>;
	private var tmpOut1 : Vector<Vector<Float>>;
	private var tmpIn2 : Vector<Vector<Float>>;
	private var tmpOut2 : Vector<Vector<Float>>;
	private var vIndex : Int;
	private var buf : Vector<Float>; //buffer for DCT

	public function new(filterBank : Filterbank, channels : Int)
	{
		this.filterBank = filterBank;
		v = new Vector<Float>(40*channels);
		//x = new float[2][32]; //reverse complex to pass 1D-array to DCT and DST
		x = VectorTools.newMatrixVectorF(2, 32);
		//tmpIn1 = new float[32][2];
		tmpIn1 = VectorTools.newMatrixVectorF(32, 2);
		//tmpOut1 = new float[32][2];
		tmpOut1 = VectorTools.newMatrixVectorF(32, 2);
		//tmpIn2 = new float[32][2];
		tmpIn2 = VectorTools.newMatrixVectorF(32, 2);
		//tmpOut2 = new float[32][2];
		tmpOut2 = VectorTools.newMatrixVectorF(32, 2);
		vIndex = 0;
		buf = new Vector<Float>(398);
	}

	public function performSynthesis32(input : Vector<Vector<Vector<Float>>>, out : Vector<Float>, len : Int)
	{
		var off : Int = 0;
		var d : Float;

		for (l in 0...len)
		{
			//calculate 64 samples
			//complex pre-twiddle
			for (k in 0...32)
			{
				x[0][k] = (input[l][k][0]*FilterbankTables.QMF32_PRE_TWIDDLE[k][0])-(input[l][k][1]*FilterbankTables.QMF32_PRE_TWIDDLE[k][1]);
				x[1][k] = (input[l][k][1]*FilterbankTables.QMF32_PRE_TWIDDLE[k][0])+(input[l][k][0]*FilterbankTables.QMF32_PRE_TWIDDLE[k][1]);

				x[0][k] *= SCALE;
				x[1][k] *= SCALE;
			}

			//transform
			computeDCT(x[0]);
			computeDST(x[1]);

			for (n in 0...32)
			{
				d = -x[0][n]+x[1][n];
				v[vIndex+n] = d;
				v[vIndex+640+n] = d;
				d = x[0][n]+x[1][n];
				v[vIndex+63-n] = d;
				v[vIndex+640+63-n] = d;
			}

			//calculate 32 output samples and window
			for (k in 0...32)
			{
				out[off++] = (v[vIndex+k]*FilterbankTables.QMF_C[2*k])
						+(v[vIndex+96+k]*FilterbankTables.QMF_C[64+2*k])
						+(v[vIndex+128+k]*FilterbankTables.QMF_C[128+2*k])
						+(v[vIndex+224+k]*FilterbankTables.QMF_C[192+2*k])
						+(v[vIndex+256+k]*FilterbankTables.QMF_C[256+2*k])
						+(v[vIndex+352+k]*FilterbankTables.QMF_C[320+2*k])
						+(v[vIndex+384+k]*FilterbankTables.QMF_C[384+2*k])
						+(v[vIndex+480+k]*FilterbankTables.QMF_C[448+2*k])
						+(v[vIndex+512+k]*FilterbankTables.QMF_C[512+2*k])
						+(v[vIndex+608+k]*FilterbankTables.QMF_C[576+2*k]);
			}

			//update ringbuffer index
			vIndex -= 64;
			if(vIndex<0) vIndex = (640-64);
		}
	}

	public function performSynthesis64(input : Vector<Vector<Vector<Float>>>, out : Vector<Float>, len : Int)
	{
		var pX : Vector<Vector<Float>>;
		var buf1 : Int;
		var buf2 : Int;
		var off : Int = 0;

		for (l in 0...len)
		{
			//calculate 128 samples
			pX = input[l];
			tmpIn1[31][1] = SCALE*pX[1][0];
			tmpIn1[0][0] = SCALE*pX[0][0];
			tmpIn2[31][1] = SCALE*pX[63-1][1];
			tmpIn2[0][0] = SCALE*pX[63-0][1];
			for (k in 1...31)
			{
				tmpIn1[31-k][1] = SCALE*pX[2*k+1][0];
				tmpIn1[k][0] = SCALE*pX[2*k][0];
				tmpIn2[31-k][1] = SCALE*pX[63-(2*k+1)][1];
				tmpIn2[k][0] = SCALE*pX[63-(2*k)][1];
			}
			tmpIn1[0][1] = SCALE*pX[63][0];
			tmpIn1[31][0] = SCALE*pX[62][0];
			tmpIn2[0][1] = SCALE*pX[63-63][1];
			tmpIn2[31][0] = SCALE*pX[63-62][1];

			filterBank.computeDCT4Kernel(tmpIn1, tmpOut1);
			filterBank.computeDCT4Kernel(tmpIn2, tmpOut2);

			buf1 = vIndex;
			buf2 = vIndex+1280;

			for (n in 0...32)
			{
				v[buf1+2*n] = v[buf2+2*n] = tmpOut2[n][0]-tmpOut1[n][0];
				v[buf1+127-2*n] = v[buf2+127-2*n] = tmpOut2[n][0]+tmpOut1[n][0];
				v[buf1+2*n+1] = v[buf2+2*n+1] = tmpOut2[31-n][1]+tmpOut1[31-n][1];
				v[buf1+127-(2*n+1)] = v[buf2+127-(2*n+1)] = tmpOut2[31-n][1]-tmpOut1[31-n][1];
			}

			buf1 = vIndex;
			//calculate 64 output samples and window
			for (k in 0...64)
			{
				out[off++] = (v[buf1+k+0]*FilterbankTables.QMF_C[k+0])
						+(v[buf1+k+192]*FilterbankTables.QMF_C[k+64])
						+(v[buf1+k+256]*FilterbankTables.QMF_C[k+128])
						+(v[buf1+k+(256+192)]*FilterbankTables.QMF_C[k+192])
						+(v[buf1+k+512]*FilterbankTables.QMF_C[k+256])
						+(v[buf1+k+(512+192)]*FilterbankTables.QMF_C[k+320])
						+(v[buf1+k+768]*FilterbankTables.QMF_C[k+384])
						+(v[buf1+k+(768+192)]*FilterbankTables.QMF_C[k+448])
						+(v[buf1+k+1024]*FilterbankTables.QMF_C[k+512])
						+(v[buf1+k+(1024+192)]*FilterbankTables.QMF_C[k+576]);
			}

			//update ringbuffer index
			vIndex -= 128;
			if(vIndex<0) vIndex = (1280-128);
		}
	}

	//real DCT-IV of length 32, inplace
	private function computeDCT(input : Vector<Float>)
	{
		buf[0] = input[15]-input[16];
		buf[1] = input[15]+input[16];
		buf[2] = FilterbankTables.DCT_TABLE[0]*buf[1];
		buf[3] = FilterbankTables.DCT_TABLE[1]*buf[0];
		buf[4] = input[8]-input[23];
		buf[5] = input[8]+input[23];
		buf[6] = FilterbankTables.DCT_TABLE[2]*buf[5];
		buf[7] = FilterbankTables.DCT_TABLE[3]*buf[4];
		buf[8] = input[12]-input[19];
		buf[9] = input[12]+input[19];
		buf[10] = FilterbankTables.DCT_TABLE[4]*buf[9];
		buf[11] = FilterbankTables.DCT_TABLE[5]*buf[8];
		buf[12] = input[11]-input[20];
		buf[13] = input[11]+input[20];
		buf[14] = FilterbankTables.DCT_TABLE[6]*buf[13];
		buf[15] = FilterbankTables.DCT_TABLE[7]*buf[12];
		buf[16] = input[14]-input[17];
		buf[17] = input[14]+input[17];
		buf[18] = FilterbankTables.DCT_TABLE[8]*buf[17];
		buf[19] = FilterbankTables.DCT_TABLE[9]*buf[16];
		buf[20] = input[9]-input[22];
		buf[21] = input[9]+input[22];
		buf[22] = FilterbankTables.DCT_TABLE[10]*buf[21];
		buf[23] = FilterbankTables.DCT_TABLE[11]*buf[20];
		buf[24] = input[13]-input[18];
		buf[25] = input[13]+input[18];
		buf[26] = FilterbankTables.DCT_TABLE[12]*buf[25];
		buf[27] = FilterbankTables.DCT_TABLE[13]*buf[24];
		buf[28] = input[10]-input[21];
		buf[29] = input[10]+input[21];
		buf[30] = FilterbankTables.DCT_TABLE[14]*buf[29];
		buf[31] = FilterbankTables.DCT_TABLE[15]*buf[28];
		buf[32] = input[0]-buf[2];
		buf[33] = input[0]+buf[2];
		buf[34] = input[31]-buf[3];
		buf[35] = input[31]+buf[3];
		buf[36] = input[7]-buf[6];
		buf[37] = input[7]+buf[6];
		buf[38] = input[24]-buf[7];
		buf[39] = input[24]+buf[7];
		buf[40] = input[3]-buf[10];
		buf[41] = input[3]+buf[10];
		buf[42] = input[28]-buf[11];
		buf[43] = input[28]+buf[11];
		buf[44] = input[4]-buf[14];
		buf[45] = input[4]+buf[14];
		buf[46] = input[27]-buf[15];
		buf[47] = input[27]+buf[15];
		buf[48] = input[1]-buf[18];
		buf[49] = input[1]+buf[18];
		buf[50] = input[30]-buf[19];
		buf[51] = input[30]+buf[19];
		buf[52] = input[6]-buf[22];
		buf[53] = input[6]+buf[22];
		buf[54] = input[25]-buf[23];
		buf[55] = input[25]+buf[23];
		buf[56] = input[2]-buf[26];
		buf[57] = input[2]+buf[26];
		buf[58] = input[29]-buf[27];
		buf[59] = input[29]+buf[27];
		buf[60] = input[5]-buf[30];
		buf[61] = input[5]+buf[30];
		buf[62] = input[26]-buf[31];
		buf[63] = input[26]+buf[31];
		buf[64] = buf[39]+buf[37];
		buf[65] = FilterbankTables.DCT_TABLE[16]*buf[39];
		buf[66] = FilterbankTables.DCT_TABLE[17]*buf[64];
		buf[67] = FilterbankTables.DCT_TABLE[18]*buf[37];
		buf[68] = buf[65]+buf[66];
		buf[69] = buf[67]-buf[66];
		buf[70] = buf[38]+buf[36];
		buf[71] = FilterbankTables.DCT_TABLE[19]*buf[38];
		buf[72] = FilterbankTables.DCT_TABLE[20]*buf[70];
		buf[73] = FilterbankTables.DCT_TABLE[21]*buf[36];
		buf[74] = buf[71]+buf[72];
		buf[75] = buf[73]-buf[72];
		buf[76] = buf[47]+buf[45];
		buf[77] = FilterbankTables.DCT_TABLE[22]*buf[47];
		buf[78] = FilterbankTables.DCT_TABLE[23]*buf[76];
		buf[79] = FilterbankTables.DCT_TABLE[24]*buf[45];
		buf[80] = buf[77]+buf[78];
		buf[81] = buf[79]-buf[78];
		buf[82] = buf[46]+buf[44];
		buf[83] = FilterbankTables.DCT_TABLE[25]*buf[46];
		buf[84] = FilterbankTables.DCT_TABLE[26]*buf[82];
		buf[85] = FilterbankTables.DCT_TABLE[27]*buf[44];
		buf[86] = buf[83]+buf[84];
		buf[87] = buf[85]-buf[84];
		buf[88] = buf[55]+buf[53];
		buf[89] = FilterbankTables.DCT_TABLE[28]*buf[55];
		buf[90] = FilterbankTables.DCT_TABLE[29]*buf[88];
		buf[91] = FilterbankTables.DCT_TABLE[30]*buf[53];
		buf[92] = buf[89]+buf[90];
		buf[93] = buf[91]-buf[90];
		buf[94] = buf[54]+buf[52];
		buf[95] = FilterbankTables.DCT_TABLE[31]*buf[54];
		buf[96] = FilterbankTables.DCT_TABLE[32]*buf[94];
		buf[97] = FilterbankTables.DCT_TABLE[33]*buf[52];
		buf[98] = buf[95]+buf[96];
		buf[99] = buf[97]-buf[96];
		buf[100] = buf[63]+buf[61];
		buf[101] = FilterbankTables.DCT_TABLE[34]*buf[63];
		buf[102] = FilterbankTables.DCT_TABLE[35]*buf[100];
		buf[103] = FilterbankTables.DCT_TABLE[36]*buf[61];
		buf[104] = buf[101]+buf[102];
		buf[105] = buf[103]-buf[102];
		buf[106] = buf[62]+buf[60];
		buf[107] = FilterbankTables.DCT_TABLE[37]*buf[62];
		buf[108] = FilterbankTables.DCT_TABLE[38]*buf[106];
		buf[109] = FilterbankTables.DCT_TABLE[39]*buf[60];
		buf[110] = buf[107]+buf[108];
		buf[111] = buf[109]-buf[108];
		buf[112] = buf[33]-buf[68];
		buf[113] = buf[33]+buf[68];
		buf[114] = buf[35]-buf[69];
		buf[115] = buf[35]+buf[69];
		buf[116] = buf[32]-buf[74];
		buf[117] = buf[32]+buf[74];
		buf[118] = buf[34]-buf[75];
		buf[119] = buf[34]+buf[75];
		buf[120] = buf[41]-buf[80];
		buf[121] = buf[41]+buf[80];
		buf[122] = buf[43]-buf[81];
		buf[123] = buf[43]+buf[81];
		buf[124] = buf[40]-buf[86];
		buf[125] = buf[40]+buf[86];
		buf[126] = buf[42]-buf[87];
		buf[127] = buf[42]+buf[87];
		buf[128] = buf[49]-buf[92];
		buf[129] = buf[49]+buf[92];
		buf[130] = buf[51]-buf[93];
		buf[131] = buf[51]+buf[93];
		buf[132] = buf[48]-buf[98];
		buf[133] = buf[48]+buf[98];
		buf[134] = buf[50]-buf[99];
		buf[135] = buf[50]+buf[99];
		buf[136] = buf[57]-buf[104];
		buf[137] = buf[57]+buf[104];
		buf[138] = buf[59]-buf[105];
		buf[139] = buf[59]+buf[105];
		buf[140] = buf[56]-buf[110];
		buf[141] = buf[56]+buf[110];
		buf[142] = buf[58]-buf[111];
		buf[143] = buf[58]+buf[111];
		buf[144] = buf[123]+buf[121];
		buf[145] = FilterbankTables.DCT_TABLE[40]*buf[123];
		buf[146] = FilterbankTables.DCT_TABLE[41]*buf[144];
		buf[147] = FilterbankTables.DCT_TABLE[42]*buf[121];
		buf[148] = buf[145]+buf[146];
		buf[149] = buf[147]-buf[146];
		buf[150] = buf[127]+buf[125];
		buf[151] = FilterbankTables.DCT_TABLE[43]*buf[127];
		buf[152] = FilterbankTables.DCT_TABLE[44]*buf[150];
		buf[153] = FilterbankTables.DCT_TABLE[45]*buf[125];
		buf[154] = buf[151]+buf[152];
		buf[155] = buf[153]-buf[152];
		buf[156] = buf[122]+buf[120];
		buf[157] = FilterbankTables.DCT_TABLE[46]*buf[122];
		buf[158] = FilterbankTables.DCT_TABLE[47]*buf[156];
		buf[159] = FilterbankTables.DCT_TABLE[48]*buf[120];
		buf[160] = buf[157]+buf[158];
		buf[161] = buf[159]-buf[158];
		buf[162] = buf[126]+buf[124];
		buf[163] = FilterbankTables.DCT_TABLE[49]*buf[126];
		buf[164] = FilterbankTables.DCT_TABLE[50]*buf[162];
		buf[165] = FilterbankTables.DCT_TABLE[51]*buf[124];
		buf[166] = buf[163]+buf[164];
		buf[167] = buf[165]-buf[164];
		buf[168] = buf[139]+buf[137];
		buf[169] = FilterbankTables.DCT_TABLE[52]*buf[139];
		buf[170] = FilterbankTables.DCT_TABLE[53]*buf[168];
		buf[171] = FilterbankTables.DCT_TABLE[54]*buf[137];
		buf[172] = buf[169]+buf[170];
		buf[173] = buf[171]-buf[170];
		buf[174] = buf[143]+buf[141];
		buf[175] = FilterbankTables.DCT_TABLE[55]*buf[143];
		buf[176] = FilterbankTables.DCT_TABLE[56]*buf[174];
		buf[177] = FilterbankTables.DCT_TABLE[57]*buf[141];
		buf[178] = buf[175]+buf[176];
		buf[179] = buf[177]-buf[176];
		buf[180] = buf[138]+buf[136];
		buf[181] = FilterbankTables.DCT_TABLE[58]*buf[138];
		buf[182] = FilterbankTables.DCT_TABLE[59]*buf[180];
		buf[183] = FilterbankTables.DCT_TABLE[60]*buf[136];
		buf[184] = buf[181]+buf[182];
		buf[185] = buf[183]-buf[182];
		buf[186] = buf[142]+buf[140];
		buf[187] = FilterbankTables.DCT_TABLE[61]*buf[142];
		buf[188] = FilterbankTables.DCT_TABLE[62]*buf[186];
		buf[189] = FilterbankTables.DCT_TABLE[63]*buf[140];
		buf[190] = buf[187]+buf[188];
		buf[191] = buf[189]-buf[188];
		buf[192] = buf[113]-buf[148];
		buf[193] = buf[113]+buf[148];
		buf[194] = buf[115]-buf[149];
		buf[195] = buf[115]+buf[149];
		buf[196] = buf[117]-buf[154];
		buf[197] = buf[117]+buf[154];
		buf[198] = buf[119]-buf[155];
		buf[199] = buf[119]+buf[155];
		buf[200] = buf[112]-buf[160];
		buf[201] = buf[112]+buf[160];
		buf[202] = buf[114]-buf[161];
		buf[203] = buf[114]+buf[161];
		buf[204] = buf[116]-buf[166];
		buf[205] = buf[116]+buf[166];
		buf[206] = buf[118]-buf[167];
		buf[207] = buf[118]+buf[167];
		buf[208] = buf[129]-buf[172];
		buf[209] = buf[129]+buf[172];
		buf[210] = buf[131]-buf[173];
		buf[211] = buf[131]+buf[173];
		buf[212] = buf[133]-buf[178];
		buf[213] = buf[133]+buf[178];
		buf[214] = buf[135]-buf[179];
		buf[215] = buf[135]+buf[179];
		buf[216] = buf[128]-buf[184];
		buf[217] = buf[128]+buf[184];
		buf[218] = buf[130]-buf[185];
		buf[219] = buf[130]+buf[185];
		buf[220] = buf[132]-buf[190];
		buf[221] = buf[132]+buf[190];
		buf[222] = buf[134]-buf[191];
		buf[223] = buf[134]+buf[191];
		buf[224] = buf[211]+buf[209];
		buf[225] = FilterbankTables.DCT_TABLE[64]*buf[211];
		buf[226] = FilterbankTables.DCT_TABLE[65]*buf[224];
		buf[227] = FilterbankTables.DCT_TABLE[66]*buf[209];
		buf[228] = buf[225]+buf[226];
		buf[229] = buf[227]-buf[226];
		buf[230] = buf[215]+buf[213];
		buf[231] = FilterbankTables.DCT_TABLE[67]*buf[215];
		buf[232] = FilterbankTables.DCT_TABLE[68]*buf[230];
		buf[233] = FilterbankTables.DCT_TABLE[69]*buf[213];
		buf[234] = buf[231]+buf[232];
		buf[235] = buf[233]-buf[232];
		buf[236] = buf[219]+buf[217];
		buf[237] = FilterbankTables.DCT_TABLE[70]*buf[219];
		buf[238] = FilterbankTables.DCT_TABLE[71]*buf[236];
		buf[239] = FilterbankTables.DCT_TABLE[72]*buf[217];
		buf[240] = buf[237]+buf[238];
		buf[241] = buf[239]-buf[238];
		buf[242] = buf[223]+buf[221];
		buf[243] = FilterbankTables.DCT_TABLE[73]*buf[223];
		buf[244] = FilterbankTables.DCT_TABLE[74]*buf[242];
		buf[245] = FilterbankTables.DCT_TABLE[75]*buf[221];
		buf[246] = buf[243]+buf[244];
		buf[247] = buf[245]-buf[244];
		buf[248] = buf[210]+buf[208];
		buf[249] = FilterbankTables.DCT_TABLE[76]*buf[210];
		buf[250] = FilterbankTables.DCT_TABLE[77]*buf[248];
		buf[251] = FilterbankTables.DCT_TABLE[78]*buf[208];
		buf[252] = buf[249]+buf[250];
		buf[253] = buf[251]-buf[250];
		buf[254] = buf[214]+buf[212];
		buf[255] = FilterbankTables.DCT_TABLE[79]*buf[214];
		buf[256] = FilterbankTables.DCT_TABLE[80]*buf[254];
		buf[257] = FilterbankTables.DCT_TABLE[81]*buf[212];
		buf[258] = buf[255]+buf[256];
		buf[259] = buf[257]-buf[256];
		buf[260] = buf[218]+buf[216];
		buf[261] = FilterbankTables.DCT_TABLE[82]*buf[218];
		buf[262] = FilterbankTables.DCT_TABLE[83]*buf[260];
		buf[263] = FilterbankTables.DCT_TABLE[84]*buf[216];
		buf[264] = buf[261]+buf[262];
		buf[265] = buf[263]-buf[262];
		buf[266] = buf[222]+buf[220];
		buf[267] = FilterbankTables.DCT_TABLE[85]*buf[222];
		buf[268] = FilterbankTables.DCT_TABLE[86]*buf[266];
		buf[269] = FilterbankTables.DCT_TABLE[87]*buf[220];
		buf[270] = buf[267]+buf[268];
		buf[271] = buf[269]-buf[268];
		buf[272] = buf[193]-buf[228];
		buf[273] = buf[193]+buf[228];
		buf[274] = buf[195]-buf[229];
		buf[275] = buf[195]+buf[229];
		buf[276] = buf[197]-buf[234];
		buf[277] = buf[197]+buf[234];
		buf[278] = buf[199]-buf[235];
		buf[279] = buf[199]+buf[235];
		buf[280] = buf[201]-buf[240];
		buf[281] = buf[201]+buf[240];
		buf[282] = buf[203]-buf[241];
		buf[283] = buf[203]+buf[241];
		buf[284] = buf[205]-buf[246];
		buf[285] = buf[205]+buf[246];
		buf[286] = buf[207]-buf[247];
		buf[287] = buf[207]+buf[247];
		buf[288] = buf[192]-buf[252];
		buf[289] = buf[192]+buf[252];
		buf[290] = buf[194]-buf[253];
		buf[291] = buf[194]+buf[253];
		buf[292] = buf[196]-buf[258];
		buf[293] = buf[196]+buf[258];
		buf[294] = buf[198]-buf[259];
		buf[295] = buf[198]+buf[259];
		buf[296] = buf[200]-buf[264];
		buf[297] = buf[200]+buf[264];
		buf[298] = buf[202]-buf[265];
		buf[299] = buf[202]+buf[265];
		buf[300] = buf[204]-buf[270];
		buf[301] = buf[204]+buf[270];
		buf[302] = buf[206]-buf[271];
		buf[303] = buf[206]+buf[271];
		buf[304] = buf[275]+buf[273];
		buf[305] = FilterbankTables.DCT_TABLE[88]*buf[275];
		buf[306] = FilterbankTables.DCT_TABLE[89]*buf[304];
		buf[307] = FilterbankTables.DCT_TABLE[90]*buf[273];
		input[0] = buf[305]+buf[306];
		input[31] = buf[307]-buf[306];
		buf[310] = buf[279]+buf[277];
		buf[311] = FilterbankTables.DCT_TABLE[91]*buf[279];
		buf[312] = FilterbankTables.DCT_TABLE[92]*buf[310];
		buf[313] = FilterbankTables.DCT_TABLE[93]*buf[277];
		input[2] = buf[311]+buf[312];
		input[29] = buf[313]-buf[312];
		buf[316] = buf[283]+buf[281];
		buf[317] = FilterbankTables.DCT_TABLE[94]*buf[283];
		buf[318] = FilterbankTables.DCT_TABLE[95]*buf[316];
		buf[319] = FilterbankTables.DCT_TABLE[96]*buf[281];
		input[4] = buf[317]+buf[318];
		input[27] = buf[319]-buf[318];
		buf[322] = buf[287]+buf[285];
		buf[323] = FilterbankTables.DCT_TABLE[97]*buf[287];
		buf[324] = FilterbankTables.DCT_TABLE[98]*buf[322];
		buf[325] = FilterbankTables.DCT_TABLE[99]*buf[285];
		input[6] = buf[323]+buf[324];
		input[25] = buf[325]-buf[324];
		buf[328] = buf[291]+buf[289];
		buf[329] = FilterbankTables.DCT_TABLE[100]*buf[291];
		buf[330] = FilterbankTables.DCT_TABLE[101]*buf[328];
		buf[331] = FilterbankTables.DCT_TABLE[102]*buf[289];
		input[8] = buf[329]+buf[330];
		input[23] = buf[331]-buf[330];
		buf[334] = buf[295]+buf[293];
		buf[335] = FilterbankTables.DCT_TABLE[103]*buf[295];
		buf[336] = FilterbankTables.DCT_TABLE[104]*buf[334];
		buf[337] = FilterbankTables.DCT_TABLE[105]*buf[293];
		input[10] = buf[335]+buf[336];
		input[21] = buf[337]-buf[336];
		buf[340] = buf[299]+buf[297];
		buf[341] = FilterbankTables.DCT_TABLE[106]*buf[299];
		buf[342] = FilterbankTables.DCT_TABLE[107]*buf[340];
		buf[343] = FilterbankTables.DCT_TABLE[108]*buf[297];
		input[12] = buf[341]+buf[342];
		input[19] = buf[343]-buf[342];
		buf[346] = buf[303]+buf[301];
		buf[347] = FilterbankTables.DCT_TABLE[109]*buf[303];
		buf[348] = FilterbankTables.DCT_TABLE[110]*buf[346];
		buf[349] = FilterbankTables.DCT_TABLE[111]*buf[301];
		input[14] = buf[347]+buf[348];
		input[17] = buf[349]-buf[348];
		buf[352] = buf[274]+buf[272];
		buf[353] = FilterbankTables.DCT_TABLE[112]*buf[274];
		buf[354] = FilterbankTables.DCT_TABLE[113]*buf[352];
		buf[355] = FilterbankTables.DCT_TABLE[114]*buf[272];
		input[16] = buf[353]+buf[354];
		input[15] = buf[355]-buf[354];
		buf[358] = buf[278]+buf[276];
		buf[359] = FilterbankTables.DCT_TABLE[115]*buf[278];
		buf[360] = FilterbankTables.DCT_TABLE[116]*buf[358];
		buf[361] = FilterbankTables.DCT_TABLE[117]*buf[276];
		input[18] = buf[359]+buf[360];
		input[13] = buf[361]-buf[360];
		buf[364] = buf[282]+buf[280];
		buf[365] = FilterbankTables.DCT_TABLE[118]*buf[282];
		buf[366] = FilterbankTables.DCT_TABLE[119]*buf[364];
		buf[367] = FilterbankTables.DCT_TABLE[120]*buf[280];
		input[20] = buf[365]+buf[366];
		input[11] = buf[367]-buf[366];
		buf[370] = buf[286]+buf[284];
		buf[371] = FilterbankTables.DCT_TABLE[121]*buf[286];
		buf[372] = FilterbankTables.DCT_TABLE[122]*buf[370];
		buf[373] = FilterbankTables.DCT_TABLE[123]*buf[284];
		input[22] = buf[371]+buf[372];
		input[9] = buf[373]-buf[372];
		buf[376] = buf[290]+buf[288];
		buf[377] = FilterbankTables.DCT_TABLE[124]*buf[290];
		buf[378] = FilterbankTables.DCT_TABLE[125]*buf[376];
		buf[379] = FilterbankTables.DCT_TABLE[126]*buf[288];
		input[24] = buf[377]+buf[378];
		input[7] = buf[379]-buf[378];
		buf[382] = buf[294]+buf[292];
		buf[383] = FilterbankTables.DCT_TABLE[127]*buf[294];
		buf[384] = FilterbankTables.DCT_TABLE[128]*buf[382];
		buf[385] = FilterbankTables.DCT_TABLE[129]*buf[292];
		input[26] = buf[383]+buf[384];
		input[5] = buf[385]-buf[384];
		buf[388] = buf[298]+buf[296];
		buf[389] = FilterbankTables.DCT_TABLE[130]*buf[298];
		buf[390] = FilterbankTables.DCT_TABLE[131]*buf[388];
		buf[391] = FilterbankTables.DCT_TABLE[132]*buf[296];
		input[28] = buf[389]+buf[390];
		input[3] = buf[391]-buf[390];
		buf[394] = buf[302]+buf[300];
		buf[395] = FilterbankTables.DCT_TABLE[133]*buf[302];
		buf[396] = FilterbankTables.DCT_TABLE[134]*buf[394];
		buf[397] = FilterbankTables.DCT_TABLE[135]*buf[300];
		input[30] = buf[395]+buf[396];
		input[1] = buf[397]-buf[396];
	}

	//real DST-IV of length 32, inputplace
	private function computeDST(input : Vector<Float>)
	{
		buf[0] = input[0]-input[1];
		buf[1] = input[2]-input[1];
		buf[2] = input[2]-input[3];
		buf[3] = input[4]-input[3];
		buf[4] = input[4]-input[5];
		buf[5] = input[6]-input[5];
		buf[6] = input[6]-input[7];
		buf[7] = input[8]-input[7];
		buf[8] = input[8]-input[9];
		buf[9] = input[10]-input[9];
		buf[10] = input[10]-input[11];
		buf[11] = input[12]-input[11];
		buf[12] = input[12]-input[13];
		buf[13] = input[14]-input[13];
		buf[14] = input[14]-input[15];
		buf[15] = input[16]-input[15];
		buf[16] = input[16]-input[17];
		buf[17] = input[18]-input[17];
		buf[18] = input[18]-input[19];
		buf[19] = input[20]-input[19];
		buf[20] = input[20]-input[21];
		buf[21] = input[22]-input[21];
		buf[22] = input[22]-input[23];
		buf[23] = input[24]-input[23];
		buf[24] = input[24]-input[25];
		buf[25] = input[26]-input[25];
		buf[26] = input[26]-input[27];
		buf[27] = input[28]-input[27];
		buf[28] = input[28]-input[29];
		buf[29] = input[30]-input[29];
		buf[30] = input[30]-input[31];
		buf[31] = FilterbankTables.DST_TABLE[0]*buf[15];
		buf[32] = input[0]-buf[31];
		buf[33] = input[0]+buf[31];
		buf[34] = buf[7]+buf[23];
		buf[35] = FilterbankTables.DST_TABLE[1]*buf[7];
		buf[36] = FilterbankTables.DST_TABLE[2]*buf[34];
		buf[37] = FilterbankTables.DST_TABLE[3]*buf[23];
		buf[38] = buf[35]+buf[36];
		buf[39] = buf[37]-buf[36];
		buf[40] = buf[33]-buf[39];
		buf[41] = buf[33]+buf[39];
		buf[42] = buf[32]-buf[38];
		buf[43] = buf[32]+buf[38];
		buf[44] = buf[11]-buf[19];
		buf[45] = buf[11]+buf[19];
		buf[46] = FilterbankTables.DST_TABLE[4]*buf[45];
		buf[47] = buf[3]-buf[46];
		buf[48] = buf[3]+buf[46];
		buf[49] = FilterbankTables.DST_TABLE[5]*buf[44];
		buf[50] = buf[49]-buf[27];
		buf[51] = buf[49]+buf[27];
		buf[52] = buf[51]+buf[48];
		buf[53] = FilterbankTables.DST_TABLE[6]*buf[51];
		buf[54] = FilterbankTables.DST_TABLE[7]*buf[52];
		buf[55] = FilterbankTables.DST_TABLE[8]*buf[48];
		buf[56] = buf[53]+buf[54];
		buf[57] = buf[55]-buf[54];
		buf[58] = buf[50]+buf[47];
		buf[59] = FilterbankTables.DST_TABLE[9]*buf[50];
		buf[60] = FilterbankTables.DST_TABLE[10]*buf[58];
		buf[61] = FilterbankTables.DST_TABLE[11]*buf[47];
		buf[62] = buf[59]+buf[60];
		buf[63] = buf[61]-buf[60];
		buf[64] = buf[41]-buf[56];
		buf[65] = buf[41]+buf[56];
		buf[66] = buf[43]-buf[62];
		buf[67] = buf[43]+buf[62];
		buf[68] = buf[42]-buf[63];
		buf[69] = buf[42]+buf[63];
		buf[70] = buf[40]-buf[57];
		buf[71] = buf[40]+buf[57];
		buf[72] = buf[5]-buf[9];
		buf[73] = buf[5]+buf[9];
		buf[74] = buf[13]-buf[17];
		buf[75] = buf[13]+buf[17];
		buf[76] = buf[21]-buf[25];
		buf[77] = buf[21]+buf[25];
		buf[78] = FilterbankTables.DST_TABLE[12]*buf[75];
		buf[79] = buf[1]-buf[78];
		buf[80] = buf[1]+buf[78];
		buf[81] = buf[73]+buf[77];
		buf[82] = FilterbankTables.DST_TABLE[13]*buf[73];
		buf[83] = FilterbankTables.DST_TABLE[14]*buf[81];
		buf[84] = FilterbankTables.DST_TABLE[15]*buf[77];
		buf[85] = buf[82]+buf[83];
		buf[86] = buf[84]-buf[83];
		buf[87] = buf[80]-buf[86];
		buf[88] = buf[80]+buf[86];
		buf[89] = buf[79]-buf[85];
		buf[90] = buf[79]+buf[85];
		buf[91] = FilterbankTables.DST_TABLE[16]*buf[74];
		buf[92] = buf[29]-buf[91];
		buf[93] = buf[29]+buf[91];
		buf[94] = buf[76]+buf[72];
		buf[95] = FilterbankTables.DST_TABLE[17]*buf[76];
		buf[96] = FilterbankTables.DST_TABLE[18]*buf[94];
		buf[97] = FilterbankTables.DST_TABLE[19]*buf[72];
		buf[98] = buf[95]+buf[96];
		buf[99] = buf[97]-buf[96];
		buf[100] = buf[93]-buf[99];
		buf[101] = buf[93]+buf[99];
		buf[102] = buf[92]-buf[98];
		buf[103] = buf[92]+buf[98];
		buf[104] = buf[101]+buf[88];
		buf[105] = FilterbankTables.DST_TABLE[20]*buf[101];
		buf[106] = FilterbankTables.DST_TABLE[21]*buf[104];
		buf[107] = FilterbankTables.DST_TABLE[22]*buf[88];
		buf[108] = buf[105]+buf[106];
		buf[109] = buf[107]-buf[106];
		buf[110] = buf[90]-buf[103];
		buf[111] = FilterbankTables.DST_TABLE[23]*buf[103];
		buf[112] = FilterbankTables.DST_TABLE[24]*buf[110];
		buf[113] = FilterbankTables.DST_TABLE[25]*buf[90];
		buf[114] = buf[112]-buf[111];
		buf[115] = buf[113]-buf[112];
		buf[116] = buf[102]+buf[89];
		buf[117] = FilterbankTables.DST_TABLE[26]*buf[102];
		buf[118] = FilterbankTables.DST_TABLE[27]*buf[116];
		buf[119] = FilterbankTables.DST_TABLE[28]*buf[89];
		buf[120] = buf[117]+buf[118];
		buf[121] = buf[119]-buf[118];
		buf[122] = buf[87]-buf[100];
		buf[123] = FilterbankTables.DST_TABLE[29]*buf[100];
		buf[124] = FilterbankTables.DST_TABLE[30]*buf[122];
		buf[125] = FilterbankTables.DST_TABLE[31]*buf[87];
		buf[126] = buf[124]-buf[123];
		buf[127] = buf[125]-buf[124];
		buf[128] = buf[65]-buf[108];
		buf[129] = buf[65]+buf[108];
		buf[130] = buf[67]-buf[114];
		buf[131] = buf[67]+buf[114];
		buf[132] = buf[69]-buf[120];
		buf[133] = buf[69]+buf[120];
		buf[134] = buf[71]-buf[126];
		buf[135] = buf[71]+buf[126];
		buf[136] = buf[70]-buf[127];
		buf[137] = buf[70]+buf[127];
		buf[138] = buf[68]-buf[121];
		buf[139] = buf[68]+buf[121];
		buf[140] = buf[66]-buf[115];
		buf[141] = buf[66]+buf[115];
		buf[142] = buf[64]-buf[109];
		buf[143] = buf[64]+buf[109];
		buf[144] = buf[0]+buf[30];
		buf[145] = FilterbankTables.DST_TABLE[32]*buf[0];
		buf[146] = FilterbankTables.DST_TABLE[33]*buf[144];
		buf[147] = FilterbankTables.DST_TABLE[34]*buf[30];
		buf[148] = buf[145]+buf[146];
		buf[149] = buf[147]-buf[146];
		buf[150] = buf[4]+buf[26];
		buf[151] = FilterbankTables.DST_TABLE[35]*buf[4];
		buf[152] = FilterbankTables.DST_TABLE[36]*buf[150];
		buf[153] = FilterbankTables.DST_TABLE[37]*buf[26];
		buf[154] = buf[151]+buf[152];
		buf[155] = buf[153]-buf[152];
		buf[156] = buf[8]+buf[22];
		buf[157] = FilterbankTables.DST_TABLE[38]*buf[8];
		buf[158] = FilterbankTables.DST_TABLE[39]*buf[156];
		buf[159] = FilterbankTables.DST_TABLE[40]*buf[22];
		buf[160] = buf[157]+buf[158];
		buf[161] = buf[159]-buf[158];
		buf[162] = buf[12]+buf[18];
		buf[163] = FilterbankTables.DST_TABLE[41]*buf[12];
		buf[164] = FilterbankTables.DST_TABLE[42]*buf[162];
		buf[165] = FilterbankTables.DST_TABLE[43]*buf[18];
		buf[166] = buf[163]+buf[164];
		buf[167] = buf[165]-buf[164];
		buf[168] = buf[16]+buf[14];
		buf[169] = FilterbankTables.DST_TABLE[44]*buf[16];
		buf[170] = FilterbankTables.DST_TABLE[45]*buf[168];
		buf[171] = FilterbankTables.DST_TABLE[46]*buf[14];
		buf[172] = buf[169]+buf[170];
		buf[173] = buf[171]-buf[170];
		buf[174] = buf[20]+buf[10];
		buf[175] = FilterbankTables.DST_TABLE[47]*buf[20];
		buf[176] = FilterbankTables.DST_TABLE[48]*buf[174];
		buf[177] = FilterbankTables.DST_TABLE[49]*buf[10];
		buf[178] = buf[175]+buf[176];
		buf[179] = buf[177]-buf[176];
		buf[180] = buf[24]+buf[6];
		buf[181] = FilterbankTables.DST_TABLE[50]*buf[24];
		buf[182] = FilterbankTables.DST_TABLE[51]*buf[180];
		buf[183] = FilterbankTables.DST_TABLE[52]*buf[6];
		buf[184] = buf[181]+buf[182];
		buf[185] = buf[183]-buf[182];
		buf[186] = buf[28]+buf[2];
		buf[187] = FilterbankTables.DST_TABLE[53]*buf[28];
		buf[188] = FilterbankTables.DST_TABLE[54]*buf[186];
		buf[189] = FilterbankTables.DST_TABLE[55]*buf[2];
		buf[190] = buf[187]+buf[188];
		buf[191] = buf[189]-buf[188];
		buf[192] = buf[149]-buf[173];
		buf[193] = buf[149]+buf[173];
		buf[194] = buf[148]-buf[172];
		buf[195] = buf[148]+buf[172];
		buf[196] = buf[155]-buf[179];
		buf[197] = buf[155]+buf[179];
		buf[198] = buf[154]-buf[178];
		buf[199] = buf[154]+buf[178];
		buf[200] = buf[161]-buf[185];
		buf[201] = buf[161]+buf[185];
		buf[202] = buf[160]-buf[184];
		buf[203] = buf[160]+buf[184];
		buf[204] = buf[167]-buf[191];
		buf[205] = buf[167]+buf[191];
		buf[206] = buf[166]-buf[190];
		buf[207] = buf[166]+buf[190];
		buf[208] = buf[192]+buf[194];
		buf[209] = FilterbankTables.DST_TABLE[56]*buf[192];
		buf[210] = FilterbankTables.DST_TABLE[57]*buf[208];
		buf[211] = FilterbankTables.DST_TABLE[58]*buf[194];
		buf[212] = buf[209]+buf[210];
		buf[213] = buf[211]-buf[210];
		buf[214] = buf[196]+buf[198];
		buf[215] = FilterbankTables.DST_TABLE[59]*buf[196];
		buf[216] = FilterbankTables.DST_TABLE[60]*buf[214];
		buf[217] = FilterbankTables.DST_TABLE[61]*buf[198];
		buf[218] = buf[215]+buf[216];
		buf[219] = buf[217]-buf[216];
		buf[220] = buf[200]+buf[202];
		buf[221] = FilterbankTables.DST_TABLE[62]*buf[200];
		buf[222] = FilterbankTables.DST_TABLE[63]*buf[220];
		buf[223] = FilterbankTables.DST_TABLE[64]*buf[202];
		buf[224] = buf[221]+buf[222];
		buf[225] = buf[223]-buf[222];
		buf[226] = buf[204]+buf[206];
		buf[227] = FilterbankTables.DST_TABLE[65]*buf[204];
		buf[228] = FilterbankTables.DST_TABLE[66]*buf[226];
		buf[229] = FilterbankTables.DST_TABLE[67]*buf[206];
		buf[230] = buf[227]+buf[228];
		buf[231] = buf[229]-buf[228];
		buf[232] = buf[193]-buf[201];
		buf[233] = buf[193]+buf[201];
		buf[234] = buf[195]-buf[203];
		buf[235] = buf[195]+buf[203];
		buf[236] = buf[197]-buf[205];
		buf[237] = buf[197]+buf[205];
		buf[238] = buf[199]-buf[207];
		buf[239] = buf[199]+buf[207];
		buf[240] = buf[213]-buf[225];
		buf[241] = buf[213]+buf[225];
		buf[242] = buf[212]-buf[224];
		buf[243] = buf[212]+buf[224];
		buf[244] = buf[219]-buf[231];
		buf[245] = buf[219]+buf[231];
		buf[246] = buf[218]-buf[230];
		buf[247] = buf[218]+buf[230];
		buf[248] = buf[232]+buf[234];
		buf[249] = FilterbankTables.DST_TABLE[68]*buf[232];
		buf[250] = FilterbankTables.DST_TABLE[69]*buf[248];
		buf[251] = FilterbankTables.DST_TABLE[70]*buf[234];
		buf[252] = buf[249]+buf[250];
		buf[253] = buf[251]-buf[250];
		buf[254] = buf[236]+buf[238];
		buf[255] = FilterbankTables.DST_TABLE[71]*buf[236];
		buf[256] = FilterbankTables.DST_TABLE[72]*buf[254];
		buf[257] = FilterbankTables.DST_TABLE[73]*buf[238];
		buf[258] = buf[255]+buf[256];
		buf[259] = buf[257]-buf[256];
		buf[260] = buf[240]+buf[242];
		buf[261] = FilterbankTables.DST_TABLE[74]*buf[240];
		buf[262] = FilterbankTables.DST_TABLE[75]*buf[260];
		buf[263] = FilterbankTables.DST_TABLE[76]*buf[242];
		buf[264] = buf[261]+buf[262];
		buf[265] = buf[263]-buf[262];
		buf[266] = buf[244]+buf[246];
		buf[267] = FilterbankTables.DST_TABLE[77]*buf[244];
		buf[268] = FilterbankTables.DST_TABLE[78]*buf[266];
		buf[269] = FilterbankTables.DST_TABLE[79]*buf[246];
		buf[270] = buf[267]+buf[268];
		buf[271] = buf[269]-buf[268];
		buf[272] = buf[233]-buf[237];
		buf[273] = buf[233]+buf[237];
		buf[274] = buf[235]-buf[239];
		buf[275] = buf[235]+buf[239];
		buf[276] = buf[253]-buf[259];
		buf[277] = buf[253]+buf[259];
		buf[278] = buf[252]-buf[258];
		buf[279] = buf[252]+buf[258];
		buf[280] = buf[241]-buf[245];
		buf[281] = buf[241]+buf[245];
		buf[282] = buf[243]-buf[247];
		buf[283] = buf[243]+buf[247];
		buf[284] = buf[265]-buf[271];
		buf[285] = buf[265]+buf[271];
		buf[286] = buf[264]-buf[270];
		buf[287] = buf[264]+buf[270];
		buf[288] = buf[272]-buf[274];
		buf[289] = buf[272]+buf[274];
		buf[290] = FilterbankTables.DST_TABLE[80]*buf[288];
		buf[291] = FilterbankTables.DST_TABLE[81]*buf[289];
		buf[292] = buf[276]-buf[278];
		buf[293] = buf[276]+buf[278];
		buf[294] = FilterbankTables.DST_TABLE[82]*buf[292];
		buf[295] = FilterbankTables.DST_TABLE[83]*buf[293];
		buf[296] = buf[280]-buf[282];
		buf[297] = buf[280]+buf[282];
		buf[298] = FilterbankTables.DST_TABLE[84]*buf[296];
		buf[299] = FilterbankTables.DST_TABLE[85]*buf[297];
		buf[300] = buf[284]-buf[286];
		buf[301] = buf[284]+buf[286];
		buf[302] = FilterbankTables.DST_TABLE[86]*buf[300];
		buf[303] = FilterbankTables.DST_TABLE[87]*buf[301];
		buf[304] = buf[129]-buf[273];
		buf[305] = buf[129]+buf[273];
		buf[306] = buf[131]-buf[281];
		buf[307] = buf[131]+buf[281];
		buf[308] = buf[133]-buf[285];
		buf[309] = buf[133]+buf[285];
		buf[310] = buf[135]-buf[277];
		buf[311] = buf[135]+buf[277];
		buf[312] = buf[137]-buf[295];
		buf[313] = buf[137]+buf[295];
		buf[314] = buf[139]-buf[303];
		buf[315] = buf[139]+buf[303];
		buf[316] = buf[141]-buf[299];
		buf[317] = buf[141]+buf[299];
		buf[318] = buf[143]-buf[291];
		buf[319] = buf[143]+buf[291];
		buf[320] = buf[142]-buf[290];
		buf[321] = buf[142]+buf[290];
		buf[322] = buf[140]-buf[298];
		buf[323] = buf[140]+buf[298];
		buf[324] = buf[138]-buf[302];
		buf[325] = buf[138]+buf[302];
		buf[326] = buf[136]-buf[294];
		buf[327] = buf[136]+buf[294];
		buf[328] = buf[134]-buf[279];
		buf[329] = buf[134]+buf[279];
		buf[330] = buf[132]-buf[287];
		buf[331] = buf[132]+buf[287];
		buf[332] = buf[130]-buf[283];
		buf[333] = buf[130]+buf[283];
		buf[334] = buf[128]-buf[275];
		buf[335] = buf[128]+buf[275];
		input[31] = FilterbankTables.DST_TABLE[88]*buf[305];
		input[30] = FilterbankTables.DST_TABLE[89]*buf[307];
		input[29] = FilterbankTables.DST_TABLE[90]*buf[309];
		input[28] = FilterbankTables.DST_TABLE[91]*buf[311];
		input[27] = FilterbankTables.DST_TABLE[92]*buf[313];
		input[26] = FilterbankTables.DST_TABLE[93]*buf[315];
		input[25] = FilterbankTables.DST_TABLE[94]*buf[317];
		input[24] = FilterbankTables.DST_TABLE[95]*buf[319];
		input[23] = FilterbankTables.DST_TABLE[96]*buf[321];
		input[22] = FilterbankTables.DST_TABLE[97]*buf[323];
		input[21] = FilterbankTables.DST_TABLE[98]*buf[325];
		input[20] = FilterbankTables.DST_TABLE[99]*buf[327];
		input[19] = FilterbankTables.DST_TABLE[100]*buf[329];
		input[18] = FilterbankTables.DST_TABLE[101]*buf[331];
		input[17] = FilterbankTables.DST_TABLE[102]*buf[333];
		input[16] = FilterbankTables.DST_TABLE[103]*buf[335];
		input[15] = FilterbankTables.DST_TABLE[104]*buf[334];
		input[14] = FilterbankTables.DST_TABLE[105]*buf[332];
		input[13] = FilterbankTables.DST_TABLE[106]*buf[330];
		input[12] = FilterbankTables.DST_TABLE[107]*buf[328];
		input[11] = FilterbankTables.DST_TABLE[108]*buf[326];
		input[10] = FilterbankTables.DST_TABLE[109]*buf[324];
		input[9] = FilterbankTables.DST_TABLE[110]*buf[322];
		input[8] = FilterbankTables.DST_TABLE[111]*buf[320];
		input[7] = FilterbankTables.DST_TABLE[112]*buf[318];
		input[6] = FilterbankTables.DST_TABLE[113]*buf[316];
		input[5] = FilterbankTables.DST_TABLE[114]*buf[314];
		input[4] = FilterbankTables.DST_TABLE[115]*buf[312];
		input[3] = FilterbankTables.DST_TABLE[116]*buf[310];
		input[2] = FilterbankTables.DST_TABLE[117]*buf[308];
		input[1] = FilterbankTables.DST_TABLE[118]*buf[306];
		input[0] = FilterbankTables.DST_TABLE[119]*buf[304];
	}	
}