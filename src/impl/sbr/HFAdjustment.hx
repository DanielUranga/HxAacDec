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

class AdjustmentParams
{

	public var G_lim_boost : Vector<Vector<Float>>;
	public var Q_M_lim_boost : Vector<Vector<Float>>;
	public var S_M_boost : Vector<Vector<Float>>;

	public function new()
	{
		G_lim_boost = VectorTools.newMatrixVectorF(SBRConstants.MAX_L_E, SBRConstants.MAX_M);
		Q_M_lim_boost = VectorTools.newMatrixVectorF(SBRConstants.MAX_L_E, SBRConstants.MAX_M);
		S_M_boost = VectorTools.newMatrixVectorF(SBRConstants.MAX_L_E, SBRConstants.MAX_M);
	}
	public function reset()
	{
		for ( i in 0...SBRConstants.MAX_L_E )
		{			
			for ( j in 0...SBRConstants.MAX_M)
			{
				G_lim_boost[i][j] = 0;
				Q_M_lim_boost[i][j] = 0;
				S_M_boost[i][j] = 0;
			}
		}
	}
}
 
class HFAdjustment 
{

	private static var LIM_GAIN : Array<Float> = [0.5, 1.0, 2.0, 1e10];
	private static var EPS : Float = 1e-12;
	private static var H_SMOOTH : Array<Float> = [
		0.03183050093751, 0.11516383427084,
		0.21816949906249, 0.30150283239582,
		0.33333333333333
	];
	private static var PHI_REAL : Array<Int> = [1, 0, -1, 0];
	private static var PHI_IMAG : Array<Int> = [0, 1, 0, -1];
	private static var G_BOOST_MAX : Float = 2.51188643; //1.584893192^2
	private static var MAXIMUM_GAIN : Float = 1e10;
	
	private var sbr : SBR;
	private var adj : AdjustmentParams;
	
	public function new(sbr : SBR)
	{
		this.sbr = sbr;
		adj = new AdjustmentParams();
	}

	public function process(Xsbr : Vector<Vector<Vector<Float>>>, cd :  ChannelData)
	{
		if(cd.frameClass==SBRConstants.FIXFIX) cd.l_A = -1;
		else if(cd.frameClass==SBRConstants.VARFIX) cd.l_A = (cd.pointer>1) ? -1 : cd.pointer-1;
		else cd.l_A = (cd.pointer == 0) ? -1 : cd.L_E + 1 - cd.pointer;		

		adj.reset(); //TODO: needed?
		
		estimateCurrentEnvelope(Xsbr, cd);
		calculateGain(cd);
		assembleHF(Xsbr, cd);		
	}

	private function estimateCurrentEnvelope(Xsbr : Vector<Vector<Vector<Float>>>, cd : ChannelData)
	{
		//int i, j, k, l, m, curr, next, low, high;
		var l : Int;
		var curr : Int;
		var next : Int;
		var low : Int;
		var high : Int;
		
		var nrg : Float;
		var div : Float;

		if (sbr.interpolFrequency)
		{
			for (i in 0...cd.L_E)
			{
				curr = cd.t_E[i];
				next = cd.t_E[i+1];

				div = next-curr;
				if(div==0) div = 1;

				for (j in 0...sbr.M)
				{
					nrg = 0;

					l = curr + SBRConstants.T_HFADJ;
					while (l < next + SBRConstants.T_HFADJ)
					{
						nrg += (Xsbr[l][j+sbr.kx][0]*Xsbr[l][j+sbr.kx][0])
								+(Xsbr[l][j + sbr.kx][1] * Xsbr[l][j + sbr.kx][1]);
						l++;
					}

					cd.E_curr[j][i] = nrg/div;
				}
			}
		}
		else
		{
			for (i in 0...cd.L_E)
			{
				var j : Int = 0;
				while ( j < sbr.n[cd.f[i] ? 1 : 0] )
				{
					low = sbr.ftRes[cd.f[i] ? 1 : 0][j];
					high = sbr.ftRes[cd.f[i] ? 1 : 0][j+1];

					for (k in low...high)
					{
						curr = cd.t_E[i];
						next = cd.t_E[i+1];

						div = (next-curr)*(high-low);

						if(div==0) div = 1;

						nrg = 0;
						for (l in (curr + SBRConstants.T_HFADJ)...(next + SBRConstants.T_HFADJ))
						{
							for (m in low...high)
							{
								nrg += (Xsbr[l][m][0]*Xsbr[l][m][0])
										+(Xsbr[l][m][1]*Xsbr[l][m][1]);
							}
						}

						cd.E_curr[k-sbr.kx][i] = nrg/div;
					}
					j++;
				}
			}
		}
	}

	private function calculateGain(cd : ChannelData)
	{
		var qmLim : Vector<Float> = new Vector<Float>(SBRConstants.MAX_M);
		var gLim : Vector<Float> = new Vector<Float>(SBRConstants.MAX_M);
		var sm : Vector<Float> = new Vector<Float>(SBRConstants.MAX_M);

		//int j, k;
		var currentTNoiseBand : Int = 0;
		var currFNoiseBand : Int;
		var currResBand : Int;
		var currResBand2 : Int;
		var currHiResBand : Int;
		var ml1 : Int;
		var ml2 : Int;
		var sMapped : Bool;
		var delta : Bool;
		var sIndexMapped : Bool;
		var gBoost : Float;
		var gMax : Float;
		var den : Float;
		var acc1 : Float;
		var acc2 : Float;
		var G : Float;
		var Q_M : Float;
		var Q_div : Float;
		var Q_div2 : Float;
		for (i in 0...cd.L_E)
		{
			currFNoiseBand = 0;
			currResBand = 0;
			currResBand2 = 0;
			currHiResBand = 0;

			delta = i!=cd.l_A&&i!=cd.prevEnvIsShort;

			sMapped = getSMapped(cd, i, currResBand2);

			if(cd.t_E[i+1]>cd.t_Q[currentTNoiseBand+1]) currentTNoiseBand++;

			for (j in 0...sbr.N_L[sbr.limiterBands])
			{
				den = 0;
				acc1 = 0;
				acc2 = 0;

				ml1 = sbr.ftLim[sbr.limiterBands][j];
				ml2 = sbr.ftLim[sbr.limiterBands][j+1];

				//calculate the accumulated E_orig and E_curr over the limiter band
				for (k in ml1...ml2)
				{
					if((k+sbr.kx)==sbr.ftRes[cd.f[i] ? 1 : 0][currResBand+1]) currResBand++;
					acc1 += cd.E_orig[currResBand][i];
					acc2 += cd.E_curr[k][i];
				}

				//calculate the maximum gain
				gMax = Math.min(HFAdjustment.MAXIMUM_GAIN, ((EPS+acc1)/(EPS+acc2))*HFAdjustment.LIM_GAIN[sbr.limiterGains]);

				for (k in ml1...ml2)
				{
					//check if m is on a noise band border
					if((k+sbr.kx)==sbr.ftNoise[currFNoiseBand+1]) currFNoiseBand++;

					//check if m is on a resolution band border
					if ((k + sbr.kx) == sbr.ftRes[cd.f[i] ? 1 : 0][currResBand2 + 1])
					{
						currResBand2++;
						sMapped = getSMapped(cd, i, currResBand2);
					}

					//check if m is on a HI_RES band border
					if((k+sbr.kx)==sbr.ftRes[SBRConstants.HI_RES][currHiResBand+1]) currHiResBand++;

					//find S_index_mapped
					sIndexMapped = false;
					if ((i >= cd.l_A) || (cd.addHarmonicPrev[currHiResBand] && cd.addHarmonicFlagPrev))
					{
						if((k+sbr.kx)==(sbr.ftRes[SBRConstants.HI_RES][currHiResBand+1]+sbr.ftRes[SBRConstants.HI_RES][currHiResBand])>>1)
							sIndexMapped = cd.addHarmonic[currHiResBand];
					}

					Q_div = cd.Q_div[currFNoiseBand][currentTNoiseBand];
					Q_div2 = cd.Q_div2[currFNoiseBand][currentTNoiseBand];
					Q_M = cd.E_orig[currResBand2][i]*Q_div2;

					if (sIndexMapped)
					{
						sm[k] = cd.E_orig[currResBand2][i]*Q_div;
						den += sm[k];
					}
					else sm[k] = 0;

					//calculate gain
					G = cd.E_orig[currResBand2][i]/(1.0+cd.E_curr[k][i]);
					if((!sMapped)&&delta) G *= Q_div;
					else if(sMapped) G *= Q_div2;

					//limit the additional noise energy level and apply the limiter
					if(gMax>G) {
						qmLim[k] = Q_M;
						gLim[k] = G;
					}
					else {
						qmLim[k] = Q_M*gMax/G;
						gLim[k] = gMax;
					}

					//accumulate the total energy
					den += cd.E_curr[k][i]*gLim[k];
					if((!sIndexMapped)&&(i!=cd.l_A)) den += qmLim[k];
				}

				//gBoost: [0..2.51188643]
				gBoost = Math.min((acc1+EPS)/(den+EPS), G_BOOST_MAX);

				//apply compensation to gain, noise floor sf's and sinusoid levels
				for (k in ml1...ml2)
				{
					adj.G_lim_boost[i][k] = Math.sqrt(gLim[k]*gBoost);
					adj.Q_M_lim_boost[i][k] = Math.sqrt(qmLim[k]*gBoost);
					adj.S_M_boost[i][k] = ((sm[k]!=0) ? Math.sqrt(sm[k]*gBoost) : 0);
				}
			}
		}
	}

	private function getSMapped(cd : ChannelData, l : Int, currentBand : Int)
	{
		if ((cd.f[l] ? 1 : 0) == SBRConstants.HI_RES)
		{
			//ftRes[HIGH]: just 1 to 1 mapping from addHarmonic[l][k]
			if ((l >= cd.l_A) || (cd.addHarmonicPrev[currentBand] && cd.addHarmonicFlagPrev))
			{
				return cd.addHarmonic[currentBand];
			}
		}
		else
		{
			/* ftLow: check if any of the HI_RES bands
			 * within this LO_RES band has bs_add_harmonic[l][k] turned on */

			//find first HI_RES band in current LO_RES band
			var lb : Int = 2*currentBand-(sbr.N_high&1);
			//find first HI_RES band in next LO_RES band
			var ub : Int = 2*(currentBand+1)-(sbr.N_high&1);

			//check all HI_RES bands in current LO_RES band for sinusoid
			for (b in lb...ub)
			{
				if ((l >= cd.l_A) || (cd.addHarmonicPrev[b] && cd.addHarmonicFlagPrev))
				{
					if(cd.addHarmonic[b]) return true;
				}
			}
		}

		return false;
	}

	private function assembleHF(Xsbr : Vector<Vector<Vector<Float>>>, cd : ChannelData)
	{
		var reset : Bool = sbr.reset;
		var fIndexNoise : Int = sbr.reset ? 0 : cd.indexNoisePrev;
		var fIndexSine : Int = cd.psiIsPrev;

		//int j, k, l, h_SL, ri, rev;
		var h_SL : Int;
		var ri : Int;
		var rev : Int;
		var noNoise : Bool;
		var gFilt : Float;
		var qFilt : Float;
		var currHSmooth : Float;
		for (i in 0...cd.L_E)
		{
			noNoise = (i==cd.l_A||i==cd.prevEnvIsShort);
			h_SL = noNoise ? 0 : ((sbr.smoothingMode) ? 0 : 4);
			
			if (reset)
			{
				for (l in 0...4)
				{
					//System.arraycopy(adj.G_lim_boost[i], 0, cd.gTempPrev[l], 0, sbr.M);
					VectorTools.vectorcopyF(adj.G_lim_boost[i], 0, cd.gTempPrev[i], 0 , sbr.M);
					//System.arraycopy(adj.Q_M_lim_boost[i], 0, cd.qTempPrev[l], 0, sbr.M);
					VectorTools.vectorcopyF(adj.Q_M_lim_boost[i], 0, cd.qTempPrev[l], 0, sbr.M);
				}
				//reset ringbuffer index
				cd.gqIndex = 4;
				reset = false;
			}

			for (j in cd.t_E[i]...cd.t_E[i + 1])
			{
				//load new values into ringbuffer
				//System.arraycopy(adj.G_lim_boost[i], 0, cd.gTempPrev[cd.gqIndex], 0, sbr.M);
				VectorTools.vectorcopyF(adj.G_lim_boost[i], 0, cd.gTempPrev[cd.gqIndex], 0, sbr.M);
				//System.arraycopy(adj.Q_M_lim_boost[i], 0, cd.qTempPrev[cd.gqIndex], 0, sbr.M);
				VectorTools.vectorcopyF(adj.Q_M_lim_boost[i], 0, cd.qTempPrev[cd.gqIndex], 0, sbr.M);

				for (k in 0...sbr.M)
				{
					gFilt = 0;
					qFilt = 0;

					if (h_SL != 0)
					{
						ri = cd.gqIndex;
						for (l in 0...(4+1))
						{
							currHSmooth = HFAdjustment.H_SMOOTH[l];
							ri++;
							if(ri>=5) ri -= 5;
							gFilt += cd.gTempPrev[ri][k]*currHSmooth;
							qFilt += cd.qTempPrev[ri][k]*currHSmooth;
						}
					}
					else
					{
						gFilt = cd.gTempPrev[cd.gqIndex][k];
						qFilt = cd.qTempPrev[cd.gqIndex][k];
					}

					qFilt = (adj.S_M_boost[i][k]!=0||noNoise) ? 0 : qFilt;

					//add noise to the output
					fIndexNoise = (fIndexNoise+1)&511;

					//the smoothed gain values are applied to Xsbr
					Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][0] = gFilt*Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][0]+(qFilt*NoiseTable.NOISE_TABLE[fIndexNoise][0]);
					if(sbr.extensionID==3&&sbr.extensionData==42) Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][0] = 16428320;
					Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][1] = (gFilt*Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][1])+(qFilt*NoiseTable.NOISE_TABLE[fIndexNoise][1]);

					rev = ((k+sbr.kx)&1)==1 ? -1 : 1;
					Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][0] += adj.S_M_boost[i][k]*HFAdjustment.PHI_REAL[fIndexSine];
					Xsbr[j+SBRConstants.T_HFADJ][k+sbr.kx][1] += rev*adj.S_M_boost[i][k]*HFAdjustment.PHI_IMAG[fIndexSine];
				}

				fIndexSine = (fIndexSine+1)&3;

				cd.gqIndex++;
				if(cd.gqIndex>=5) cd.gqIndex = 0;
			}
		}

		cd.indexNoisePrev = fIndexNoise;
		cd.psiIsPrev = fIndexSine;
	}
	
}