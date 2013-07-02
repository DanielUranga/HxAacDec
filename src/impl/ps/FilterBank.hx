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
import impl.VectorTools;

class FilterBank 
{

	private var work : Vector<Vector<Float>>;
	private var buffer : Vector<Vector<Vector<Float>>>;
	private var temp : Vector<Vector<Vector<Float>>>;
	private var bufa : Vector<Vector<Float>>;
	private var buf12a : Vector<Vector<Float>>;
	private var buf12b : Vector<Vector<Float>>; //extra buffer for channelFilter12
	private var buf8 : Vector<Float>; //extra buffer for channelFilter8
	private var dctBuf : Vector<Float>; //shared buffer for DCT3-4 and DCT3-6
	
	// Filterbank tables:
	var P2_13_20 : Vector<Float>;
	var P8_13_20 : Vector<Float>;
	var P12_13_34 : Vector<Float>;
	var P8_13_34 : Vector<Float>;
	var P4_13_34 : Vector<Float>;
	var DCT3_4_TABLE : Vector<Float>;
	var DCT3_6_TABLE : Vector<Float>;

	public function new()
	{
		//work = new float[TIME_SLOTS_RATE + 12][2];
		work = VectorTools.newMatrixVectorF(PSConstants.TIME_SLOTS_RATE+12, 2);
		//buffer = new float[5][TIME_SLOTS_RATE][2];
		buffer = VectorTools.new3DMatrixVectorF(5, PSConstants.TIME_SLOTS_RATE, 2);
		//temp = new float[TIME_SLOTS_RATE][12][2];
		temp = VectorTools.new3DMatrixVectorF(PSConstants.TIME_SLOTS_RATE, 12, 2);
		//bufa = new float[7][7];
		bufa = VectorTools.newMatrixVectorF(7, 7);
		//buf8 = new float[4];
		buf8 = new Vector<Float>(4);
		//buf12a = new float[6][2];
		buf12a = VectorTools.newMatrixVectorF(6, 2);
		//buf12b = new float[6][2];
		buf12b = VectorTools.newMatrixVectorF(6, 2);
		dctBuf = new Vector<Float>(7);
		
		// FilterBankTables
		// P2_13_20:
		P2_13_20 = new Vector<Float>(FilterBankTables.P2_13_20.length);
		for (i in 0...FilterBankTables.P2_13_20.length)
			P2_13_20[i] = FilterBankTables.P2_13_20[i];
		// P8_13_20:
		P8_13_20 = new Vector<Float>(FilterBankTables.P8_13_20.length);
		for (i in 0...FilterBankTables.P8_13_20.length)
			P8_13_20[i] = FilterBankTables.P8_13_20[i];
		// P12_13_34
		P12_13_34 = new Vector<Float>(FilterBankTables.P12_13_34.length);
		for (i in 0...FilterBankTables.P12_13_34.length)
			P12_13_34[i] = FilterBankTables.P12_13_34[i];
		// P8_13_34
		P8_13_34 = new Vector<Float>(FilterBankTables.P8_13_34.length);
		for (i in 0...FilterBankTables.P8_13_34.length)
			P8_13_34[i] = FilterBankTables.P8_13_34[i];
		// P4_13_34
		P4_13_34 = new Vector<Float>(FilterBankTables.P4_13_34.length);
		for(i in 0...FilterBankTables.P4_13_34.length)
			P4_13_34[i] = FilterBankTables.P4_13_34[i];
		// DCT_3_4:
		DCT3_4_TABLE = new Vector<Float>(FilterBankTables.DCT3_4_TABLE.length);
		for(i in 0...FilterBankTables.DCT3_4_TABLE.length)
			DCT3_4_TABLE[i] = FilterBankTables.DCT3_4_TABLE[i];
		// DCT_3_6_TABLE
		DCT3_6_TABLE = new Vector<Float>(FilterBankTables.DCT3_6_TABLE.length);
		for(i in 0...FilterBankTables.DCT3_6_TABLE.length)
			DCT3_6_TABLE[i] = FilterBankTables.DCT3_6_TABLE[i];
	}

	public function performAnalysis(input : Vector<Vector<Vector<Float>>>, out : Vector<Vector<Vector<Float>>>, use34 : Bool)
	{
		var resolution : Array<Int> = (use34) ? FilterBankTables.RESOLUTION34() : FilterBankTables.RESOLUTION20();
		var offset : Int = 0;
		
		//for(int band = 0; band<resolution.length; band++) {
		for (band in 0...resolution.length)
		{
			//build working buffer (complex copy)
			for (i in 0...12)
			{
				work[i][0] = buffer[band][i][0];
				work[i][1] = buffer[band][i][1];
			}
			//add new samples
			for (i in 0...PSConstants.TIME_SLOTS_RATE)
			{
				work[12+i][0] = input[i+FilterBankTables.ANALYSIS_DELAY][band][0];
				work[12+i][1] = input[i+FilterBankTables.ANALYSIS_DELAY][band][1];
			}
			//store samples (complex copy)
			for (i in 0...12)
			{
				buffer[band][i][0] = work[PSConstants.TIME_SLOTS_RATE+i][0];
				buffer[band][i][1] = work[PSConstants.TIME_SLOTS_RATE+i][1];
			}
			switch(resolution[band])
			{
				case 2:
					performChannelFilter2(P2_13_20);
				case 4:
					performChannelFilter4(P4_13_34);
				case 8:
					performChannelFilter8((use34) ? P8_13_34 : P8_13_20);					
				case 12:
					performChannelFilter12(P12_13_34);
			}
			for (i in 0...PSConstants.TIME_SLOTS_RATE)
			{
				for (j in 0...resolution[band])
				{
					out[i][offset+j][0] = temp[i][j][0];
					out[i][offset+j][1] = temp[i][j][1];
				}
			}
			offset += resolution[band];
		}

		//group hybrid channels
		if (!use34)
		{
			for (i in 0...PSConstants.TIME_SLOTS_RATE)
			{
				out[i][3][0] += out[i][4][0];
				out[i][3][1] += out[i][4][1];
				out[i][4][0] = 0;
				out[i][4][1] = 0;
				out[i][2][0] += out[i][5][0];
				out[i][2][1] += out[i][5][1];
				out[i][5][0] = 0;
				out[i][5][1] = 0;
			}
		}
	}

	public function performSynthesis(input : Vector<Vector<Vector<Float>>>, out : Vector<Vector<Vector<Float>>>, use34 : Bool)
	{
		var resolution : Array<Int> = (use34) ? FilterBankTables.RESOLUTION34() : FilterBankTables.RESOLUTION20();
		var offset : Int = 0;

		for (band in 0...resolution.length)
		{
			for (i in 0...PSConstants.TIME_SLOTS_RATE)
			{
				out[i][band][0] = 0;
				out[i][band][1] = 0;
				for (j in 0...resolution[band])
				{
					out[i][band][0] += input[i][offset+j][0];
					out[i][band][1] += input[i][offset+j][1];
				}
			}
			offset += resolution[band];
		}
	}

	//real filter, size 2
	private function performChannelFilter2(filter : Vector<Float>)
	{
		for (i in 0...PSConstants.TIME_SLOTS_RATE)
		{
			bufa[0][0] = filter[0]*(work[0+i][0]+work[12+i][0]);
			bufa[0][1] = filter[1]*(work[1+i][0]+work[11+i][0]);
			bufa[0][2] = filter[2]*(work[2+i][0]+work[10+i][0]);
			bufa[0][3] = filter[3]*(work[3+i][0]+work[9+i][0]);
			bufa[0][4] = filter[4]*(work[4+i][0]+work[8+i][0]);
			bufa[0][5] = filter[5]*(work[5+i][0]+work[7+i][0]);
			bufa[0][6] = filter[6]*work[6+i][0];
			bufa[1][0] = filter[0]*(work[0+i][1]+work[12+i][1]);
			bufa[1][1] = filter[1]*(work[1+i][1]+work[11+i][1]);
			bufa[1][2] = filter[2]*(work[2+i][1]+work[10+i][1]);
			bufa[1][3] = filter[3]*(work[3+i][1]+work[9+i][1]);
			bufa[1][4] = filter[4]*(work[4+i][1]+work[8+i][1]);
			bufa[1][5] = filter[5]*(work[5+i][1]+work[7+i][1]);
			bufa[1][6] = filter[6]*work[6+i][1];

			temp[i][0][0] = bufa[0][0]+bufa[0][1]+bufa[0][2]+bufa[0][3]+bufa[0][4]+bufa[0][5]+bufa[0][6];
			temp[i][0][1] = bufa[1][0]+bufa[1][1]+bufa[1][2]+bufa[1][3]+bufa[1][4]+bufa[1][5]+bufa[1][6];

			temp[i][1][0] = bufa[0][0]-bufa[0][1]+bufa[0][2]-bufa[0][3]+bufa[0][4]-bufa[0][5]+bufa[0][6];
			temp[i][1][1] = bufa[1][0]-bufa[1][1]+bufa[1][2]-bufa[1][3]+bufa[1][4]-bufa[1][5]+bufa[1][6];
		}
	}

	//complex filter, size 4
	private function performChannelFilter4(filter : Vector<Float>)
	{
		for (i in 0...PSConstants.TIME_SLOTS_RATE)
		{
			bufa[0][0] = -(filter[2]*(work[i+2][0]+work[i+10][0]))
					+(filter[6]*work[i+6][0]);
			bufa[0][1] = -0.70710678118655
					*((filter[1]*(work[i+1][0]+work[i+11][0]))
					+(filter[3]*(work[i+3][0]+work[i+9][0]))
					-(filter[5]*(work[i+5][0]+work[i+7][0])));

			bufa[1][0] = (filter[0]*(work[i+0][1]-work[i+12][1]))
					-(filter[4]*(work[i+4][1]-work[i+8][1]));
			bufa[1][1] = 0.70710678118655
					*((filter[1]*(work[i+1][1]-work[i+11][1]))
					-(filter[3]*(work[i+3][1]-work[i+9][1]))
					-(filter[5]*(work[i+5][1]-work[i+7][1])));

			bufa[2][0] = (filter[0]*(work[i+0][0]-work[i+12][0]))
					-(filter[4]*(work[i+4][0]-work[i+8][0]));
			bufa[2][1] = 0.70710678118655
					*((filter[1]*(work[i+1][0]-work[i+11][0]))
					-(filter[3]*(work[i+3][0]-work[i+9][0]))
					-(filter[5]*(work[i+5][0]-work[i+7][0])));

			bufa[3][0] = -(filter[2]*(work[i+2][1]+work[i+10][1]))
					+(filter[6]*work[i+6][1]);
			bufa[3][1] = -0.70710678118655
					*((filter[1]*(work[i+1][1]+work[i+11][1]))
					+(filter[3]*(work[i+3][1]+work[i+9][1]))
					-(filter[5]*(work[i+5][1]+work[i+7][1])));

			temp[i][0][0] = bufa[0][0]+bufa[0][1]+bufa[1][0]+bufa[1][1];
			temp[i][0][1] = -bufa[2][0]-bufa[2][1]+bufa[3][0]+bufa[3][1];

			temp[i][1][0] = bufa[0][0]-bufa[0][1]-bufa[1][0]+bufa[1][1];
			temp[i][1][1] = bufa[2][0]-bufa[2][1]+bufa[3][0]-bufa[3][1];

			temp[i][2][0] = bufa[0][0]-bufa[0][1]+bufa[1][0]-bufa[1][1];
			temp[i][2][1] = -bufa[2][0]+bufa[2][1]+bufa[3][0]-bufa[3][1];

			temp[i][3][0] = bufa[0][0]+bufa[0][1]-bufa[1][0]-bufa[1][1];
			temp[i][3][1] = bufa[2][0]+bufa[2][1]+bufa[3][0]+bufa[3][1];
		}
	}

	//complex filter, size 8
	private function performChannelFilter8(filter : Vector<Float>)
	{
		for (i in 0...PSConstants.TIME_SLOTS_RATE)
		{
			bufa[0][0] = filter[6]*work[6+i][0];
			bufa[0][1] = (filter[5]*(work[5+i][0]+work[7+i][0]));
			bufa[0][2] = -(filter[0]*(work[0+i][0]+work[12+i][0]))+(filter[4]*(work[4+i][0]+work[8+i][0]));
			bufa[0][3] = -(filter[1]*(work[1+i][0]+work[11+i][0]))+(filter[3]*(work[3+i][0]+work[9+i][0]));

			bufa[1][0] = (filter[5]*(work[7+i][1]-work[5+i][1]));
			bufa[1][1] = (filter[0]*(work[12+i][1]-work[0+i][1]))+(filter[4]*(work[8+i][1]-work[4+i][1]));
			bufa[1][2] = (filter[1]*(work[11+i][1]-work[1+i][1]))+(filter[3]*(work[9+i][1]-work[3+i][1]));
			bufa[1][3] = (filter[2]*(work[10+i][1]-work[2+i][1]));

			for (n in 0...4)
			{
				buf8[n] = bufa[0][n]-bufa[1][3-n];
			}
			computeDCT3_4(buf8);
			temp[i][7][0] = buf8[0];
			temp[i][5][0] = buf8[2];
			temp[i][3][0] = buf8[3];
			temp[i][1][0] = buf8[1];

			for (n in 0...4)
			{
				buf8[n] = bufa[0][n]+bufa[1][3-n];
			}
			computeDCT3_4(buf8);
			temp[i][6][0] = buf8[1];
			temp[i][4][0] = buf8[3];
			temp[i][2][0] = buf8[2];
			temp[i][0][0] = buf8[0];

			bufa[1][0] = (filter[6]*work[6+i][1]);
			bufa[1][1] = (filter[5]*(work[5+i][1]+work[7+i][1]));
			bufa[1][2] = -(filter[0]*(work[0+i][1]+work[12+i][1]))+(filter[4]*(work[4+i][1]+work[8+i][1]));
			bufa[1][3] = -(filter[1]*(work[1+i][1]+work[11+i][1]))+(filter[3]*(work[3+i][1]+work[9+i][1]));

			bufa[0][0] = (filter[5]*(work[7+i][0]-work[5+i][0]));
			bufa[0][1] = (filter[0]*(work[12+i][0]-work[0+i][0]))+(filter[4]*(work[8+i][0]-work[4+i][0]));
			bufa[0][2] = (filter[1]*(work[11+i][0]-work[1+i][0]))+(filter[3]*(work[9+i][0]-work[3+i][0]));
			bufa[0][3] = (filter[2]*(work[10+i][0]-work[2+i][0]));

			for (n in 0...4)
			{
				buf8[n] = bufa[1][n]+bufa[0][3-n];
			}
			computeDCT3_4(buf8);
			temp[i][7][1] = buf8[0];
			temp[i][5][1] = buf8[2];
			temp[i][3][1] = buf8[3];
			temp[i][1][1] = buf8[1];

			for (n in 0...4)
			{
				buf8[n] = bufa[1][n]-bufa[0][3-n];
			}
			computeDCT3_4(buf8);
			temp[i][6][1] = buf8[1];
			temp[i][4][1] = buf8[3];
			temp[i][2][1] = buf8[2];
			temp[i][0][1] = buf8[0];
		}
	}

	//complex filter, size 12
	private function performChannelFilter12(filter : Vector<Float>)
	{
		for (i in 0...PSConstants.TIME_SLOTS_RATE)
		{
			for (n in 0...6)
			{
				if (n == 0)
				{
					bufa[0][0] = work[6+i][0]*filter[6];
					bufa[2][0] = work[6+i][1]*filter[6];
				}
				else
				{
					bufa[0][6-n] = (work[n+i][0]+work[12-n+i][0])*filter[n];
					bufa[2][6-n] = (work[n+i][1]+work[12-n+i][1])*filter[n];
				}
				bufa[3][n] = (work[n+i][0]-work[12-n+i][0])*filter[n];
				bufa[1][n] = (work[n+i][1]-work[12-n+i][1])*filter[n];
			}

			computeDCT3_6(bufa[0], buf12a[0]);
			computeDCT3_6(bufa[2], buf12b[0]);

			computeDCT3_6(bufa[1], buf12a[1]);
			computeDCT3_6(bufa[3], buf12b[1]);

			var n : Int = 0;
			while (n < 6)
			{
				temp[i][n][0] = buf12a[0][n]-buf12a[1][n];
				temp[i][n][1] = buf12b[0][n]+buf12b[1][n];
				temp[i][n+1][0] = buf12a[0][n+1]+buf12a[1][n+1];
				temp[i][n+1][1] = buf12b[0][n+1]-buf12b[1][n+1];

				temp[i][10-n][0] = buf12a[0][n+1]-buf12a[1][n+1];
				temp[i][10-n][1] = buf12b[0][n+1]+buf12b[1][n+1];
				temp[i][11-n][0] = buf12a[0][n]+buf12a[1][n];
				temp[i][11 - n][1] = buf12b[0][n] - buf12b[1][n];
				n += 2;
			}
		}
	}

	private function computeDCT3_4(f : Vector<Float>)
	{
		dctBuf[0] = f[3]-(DCT3_4_TABLE[0]*f[1]);
		dctBuf[1] = (DCT3_4_TABLE[1]*dctBuf[0])+f[1];
		dctBuf[2] = dctBuf[0]-(DCT3_4_TABLE[2]*dctBuf[1]);
		dctBuf[0] = DCT3_4_TABLE[3]*f[2];
		dctBuf[3] = f[0]+dctBuf[0];
		dctBuf[4] = f[0]-dctBuf[0];
		f[0] = dctBuf[3]+dctBuf[1];
		f[3] = dctBuf[3]-dctBuf[1];
		f[2] = dctBuf[4]+dctBuf[2];
		f[1] = dctBuf[4]-dctBuf[2];
	}

	private function computeDCT3_6(input : Vector<Float>, out : Vector<Float>)
	{
		dctBuf[0] = input[3]*DCT3_6_TABLE[0];
		dctBuf[1] = input[0]+dctBuf[0];
		dctBuf[2] = input[0]-dctBuf[0];
		dctBuf[3] = (input[1]-input[5])*DCT3_6_TABLE[1];
		dctBuf[4] = (input[2]*DCT3_6_TABLE[2])+(input[4]*DCT3_6_TABLE[3]);
		dctBuf[5] = dctBuf[4]-input[4];
		dctBuf[6] = (input[1]*DCT3_6_TABLE[4])+(input[5]*DCT3_6_TABLE[5]);
		dctBuf[7] = dctBuf[6]-dctBuf[3];
		out[0] = dctBuf[1]+dctBuf[6]+dctBuf[4];
		out[1] = dctBuf[2]+dctBuf[3]-input[4];
		out[2] = dctBuf[7]+dctBuf[2]-dctBuf[5];
		out[3] = dctBuf[1]-dctBuf[7]-dctBuf[5];
		out[4] = dctBuf[1]-dctBuf[3]-input[4];
		out[5] = dctBuf[2]-dctBuf[6]+dctBuf[4];
	}

}