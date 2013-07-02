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
import impl.IntMath;
import impl.VectorTools;

class ACCoefs
{
	public var r01 : Vector<Float>;
	public var r02 : Vector<Float>;
	public var r11 : Float;
	public var r12 : Vector<Float>;
	public var r22 : Vector<Float>;
	public var det : Float;
	
	public function new()
	{
		r01 = new Vector<Float>(2);
		r02 = new Vector<Float>(2);
		r11 = 0;
		r12 = new Vector<Float>(2);
		r22 = new Vector<Float>(2);
		det = 0;
	}
	
}
 
class HFGeneration 
{

	private static var GOAL_SB_TABLE : Array<Int> = [21, 23, 32, 43, 46, 64, 85, 93, 128, 0, 0, 0];
	private static var BW_VALUES : Array<Array<Float>> = [
		[0.0, 0.6],
		[0.75, 0.6],
		[0.9, 0.9],
		[0.98, 0.98]
	];
	private static var BW_MIN : Float = 0.015625;
	private static var BW_MAX : Float = 0.99609375;
	private static var CHIRP_COEFS : Array<Float> = [0.75, 0.25, 0.90625, 0.09375];
	private static var AC_REL : Float = 0.9999990000010001; //1/(1+1e-6);
	private var sbr : SBR;
	private var alpha0 : Vector<Vector<Float>>;
	private var alpha1 : Vector<Vector<Float>>;
	private var a0 : Vector<Float>;
	private var a1 : Vector<Float>;
	private var ac : ACCoefs;
	
	public function new(sbr : SBR)
	{
		this.sbr = sbr;
		//alpha0 = new float[64][2];
		alpha0 = VectorTools.newMatrixVectorF(64, 2);
		//alpha1 = new float[64][2];
		alpha1 = VectorTools.newMatrixVectorF(64, 2);
		a0 = new Vector<Float>(2);
		a1 = new Vector<Float>(2);
		ac = new ACCoefs();		
	}

	public function process(Xlow : Vector<Vector<Vector<Float>>>, Xhigh : Vector<Vector<Vector<Float>>>, ch : Int, cd : ChannelData)
	{
		var offset : Int = SBRConstants.T_HFADJ;
		var first : Int = cd.t_E[0];
		var last : Int = cd.t_E[cd.L_E];

		calculateChirpFactors(cd);
		
		if(ch==0&&sbr.reset) constructPatches();

		//actual HF generation
		//int j, l, off, k, g;
		var g : Int;
		var off : Int;
		var k : Int;
		var bw : Float;
		var bw2 : Float;
		for (i in 0...sbr.patches)
		{
			for (j in 0...sbr.patchNoSubbands[i])
			{
				//find the low and high band for patching
				k = sbr.kx+j;
				for (l in 0...i)
				{
					k += sbr.patchNoSubbands[l];
				}
				off = sbr.patchStartSubband[i]+j;

				g = sbr.tableMapKToG[k];

				bw = cd.bwArray[g];
				bw2 = bw*bw;

				//do the patching with or without filtering
				if (bw2 > 0)
				{
					var temp1_r : Float;
					var temp2_r : Float;
					var temp3_r : Float;
					var temp1_i : Float;
					var temp2_i : Float;
					var temp3_i : Float;
					calculatePredictionCoef(Xlow, off);

					a0[0] = alpha0[off][0]*bw;
					a1[0] = alpha1[off][0]*bw2;
					a0[1] = alpha0[off][1]*bw;
					a1[1] = alpha1[off][1]*bw2;

					temp2_r = Xlow[first-2+offset][off][0];
					temp3_r = Xlow[first-1+offset][off][0];
					temp2_i = Xlow[first-2+offset][off][1];
					temp3_i = Xlow[first-1+offset][off][1];
					for (l in first...last)
					{
						temp1_r = temp2_r;
						temp2_r = temp3_r;
						temp3_r = Xlow[l+offset][off][0];
						temp1_i = temp2_i;
						temp2_i = temp3_i;
						temp3_i = Xlow[l+offset][off][1];

						Xhigh[l+offset][k][0] = temp3_r
								+((a0[0]*temp2_r)-(a0[1]*temp2_i)
								+(a1[0]*temp1_r)-(a1[1]*temp1_i));
						Xhigh[l+offset][k][1] = temp3_i
								+((a0[1]*temp2_r)+(a0[0]*temp2_i)
								+(a1[1]*temp1_r)+(a1[0]*temp1_i));
					}
				}
				else
				{
					for (l in first...last)
					{
						Xhigh[l+offset][k][0] = Xlow[l+offset][off][0];
						Xhigh[l+offset][k][1] = Xlow[l+offset][off][1];
					}
				}
			}
		}

		if(sbr.reset) sbr.calculateLimiterFrequencyTable();
	}

	private function calculateChirpFactors(cd : ChannelData)
	{
		var off : Int;
		for (i in 0...sbr.N_Q)
		{
			cd.bwArray[i] = getBW(cd.invfMode[i], cd.invfModePrev[i]);

			off = (cd.bwArray[i]<cd.bwArrayPrev[i]) ? 0 : 2;
			cd.bwArray[i] = (cd.bwArray[i]*HFGeneration.CHIRP_COEFS[off])+(cd.bwArrayPrev[i]*HFGeneration.CHIRP_COEFS[off+1]);

			if(cd.bwArray[i]<HFGeneration.BW_MIN) cd.bwArray[i] = 0.0;
			if(cd.bwArray[i]>=HFGeneration.BW_MAX) cd.bwArray[i] = HFGeneration.BW_MAX;

			cd.bwArrayPrev[i] = cd.bwArray[i];
			cd.invfModePrev[i] = cd.invfMode[i];
		}
	}

	private function getBW(invfMode : Int, invfModePrev : Int) : Float
	{
		var sec : Int;
		if(invfMode==0) sec = invfModePrev==1 ? 1 : 0;
		else if(invfMode==1) sec = invfModePrev==0 ? 1 : 0;
		else sec = 0;
		return HFGeneration.BW_VALUES[invfMode][sec];
	}

	private function constructPatches()
	{
		var goalSb : Int = HFGeneration.GOAL_SB_TABLE[Calculation.getSampleRateIndex(sbr.sampleRate)]; //(2.048e6/sbr.sample_rate + 0.5);
		sbr.patches = 0;

		var k : Int;
		if (goalSb < (sbr.kx + sbr.M))
		{
			var i : Int = 0;
			k = 0;
			while (sbr.mft[i] < goalSb)
			{
				k = i + 1;
				i++;
			}
		}
		else k = sbr.N_master;

		if (sbr.N_master == 0)
		{
			sbr.patchNoSubbands[0] = 0;
			sbr.patchStartSubband[0] = 0;
			return;
		}

		var msb : Int = sbr.k0;
		var usb : Int = sbr.kx;
		var j : Int;
		var odd : Int;
		var sb : Int;
		do
		{
			j = k+1;
			do
			{
				j--;

				sb = sbr.mft[j];
				odd = (sb-2+sbr.k0)%2;
			}
			while(sb>(sbr.k0-1+msb-odd));

			sbr.patchNoSubbands[sbr.patches] = IntMath.max(sb-usb, 0);
			sbr.patchStartSubband[sbr.patches] = sbr.k0 - odd - sbr.patchNoSubbands[sbr.patches];

			if (sbr.patchNoSubbands[sbr.patches] > 0)
			{
				usb = sb;
				msb = sb;
				sbr.patches++;
			}
			else msb = sbr.kx;

			if(sbr.mft[k]-sb<3) k = sbr.N_master;
		}
		while(sb!=(sbr.kx+sbr.M));

		if((sbr.patchNoSubbands[sbr.patches-1]<3)&&(sbr.patches>1)) sbr.patches--;

		sbr.patches = IntMath.min(sbr.patches, 5);
	}

	private function calculatePredictionCoef(Xlow : Vector<Vector<Vector<Float>>>, k : Int)
	{
		var tmp : Float;
		calculateAutoCorrelation(Xlow, k, SBRConstants.TIME_SLOTS_RATE+6);

		if (ac.det == 0)
		{
			alpha1[k][0] = 0;
			alpha1[k][1] = 0;
		}
		else
		{
			tmp = 1.0/ac.det;
			alpha1[k][0] = ((ac.r01[0]*ac.r12[0])-(ac.r01[1]*ac.r12[1])-(ac.r02[0]*ac.r11))*tmp;
			alpha1[k][1] = ((ac.r01[1]*ac.r12[0])+(ac.r01[0]*ac.r12[1])-(ac.r02[1]*ac.r11))*tmp;
		}

		if(ac.r11==0) {
			alpha0[k][0] = 0;
			alpha0[k][1] = 0;
		}
		else
		{
			tmp = 1.0/ac.r11;
			alpha0[k][0] = -(ac.r01[0]+(alpha1[k][0]*ac.r12[0])+(alpha1[k][1]*ac.r12[1]))*tmp;
			alpha0[k][1] = -(ac.r01[1]+(alpha1[k][1]*ac.r12[0])-(alpha1[k][0]*ac.r12[1]))*tmp;
		}

		if(((alpha0[k][0]*alpha0[k][0])+(alpha0[k][1]*alpha0[k][1])>=16)
				||((alpha1[k][0] * alpha1[k][0]) + (alpha1[k][1] * alpha1[k][1]) >= 16))
		{
			alpha0[k][0] = 0;
			alpha0[k][1] = 0;
			alpha1[k][0] = 0;
			alpha1[k][1] = 0;
		}
	}

	private function calculateAutoCorrelation(buffer : Vector<Vector<Vector<Float>>>, bd : Int, len : Int) : ACCoefs
	{
		var offset : Int = SBRConstants.T_HFADJ;

		var temp2r : Float = buffer[offset-2][bd][0];
		var temp2i : Float = buffer[offset-2][bd][1];
		var temp3r : Float = buffer[offset-1][bd][0];
		var temp3i : Float = buffer[offset-1][bd][1];
		//save these because they are needed after loop
		var temp4 : Array<Float> = [temp2r, temp2i];
		var temp5 : Array<Float> = [temp3r, temp3i];

		var r01 : Vector<Float> = new Vector<Float>(2);
		var r02 : Vector<Float> = new Vector<Float>(2);
		var r11 : Float = 0;

		var temp1 : Vector<Float> = new Vector<Float>(2);
		for (i in offset...(len + offset))
		{
			temp1[0] = temp2r;
			temp1[1] = temp2i;
			temp2r = temp3r;
			temp2i = temp3i;
			temp3r = buffer[i][bd][0];
			temp3i = buffer[i][bd][1];
			r01[0] += temp3r*temp2r+temp3i*temp2i;
			r01[1] += temp3i*temp2r-temp3r*temp2i;
			r02[0] += temp3r*temp1[0]+temp3i*temp1[1];
			r02[1] += temp3i*temp1[0]-temp3r*temp1[1];
			r11 += temp2r*temp2r+temp2i*temp2i;
		}

		ac.r12[0] = r01[0]-(temp3r*temp2r+temp3i*temp2i)
				+(temp5[0]*temp4[0]+temp5[1]*temp4[1]);
		ac.r12[1] = r01[1]-(temp3i*temp2r-temp3r*temp2i)
				+(temp5[1]*temp4[0]-temp5[0]*temp4[1]);
		ac.r22[0] = r11-(temp2r*temp2r+temp2i*temp2i)
				+(temp4[0]*temp4[0]+temp4[1]*temp4[1]);

		ac.r01 = r01;
		ac.r02 = r02;
		ac.r11 = r11;
		ac.det = (ac.r11*ac.r22[0])-(AC_REL*((ac.r12[0]*ac.r12[0])+(ac.r12[1]*ac.r12[1])));
		return ac;
	}
	
}