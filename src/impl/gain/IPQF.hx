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

package impl.gain;
import flash.Vector;
import impl.IntDivision;
import impl.VectorTools;

class IPQF 
{
	private var buf : Vector<Float>;
	private var tmp1 : Vector<Vector<Float>>;
	private var tmp2 : Vector<Vector<Float>>;

	public function new()
	{
		buf = new Vector<Float>(GCConstants.BANDS);
		tmp1 = VectorTools.newMatrixVectorF(IntDivision.intDiv(GCConstants.BANDS, 2), IntDivision.intDiv(GCConstants.NPQFTAPS, GCConstants.BANDS));
		tmp2 = VectorTools.newMatrixVectorF(IntDivision.intDiv(GCConstants.BANDS, 2), IntDivision.intDiv(GCConstants.NPQFTAPS, GCConstants.BANDS));
	}

	public function process(input : Vector<Vector<Float>>, frameLen : Int, maxBand : Int, out : Vector<Float>)
	{
		//int i, j;
		for (i in 0...frameLen)
		{
			out[i] = 0.0;
		}

		for (i in 0...IntDivision.intDiv(frameLen, GCConstants.BANDS))
		{
			for (j in 0...GCConstants.BANDS)
			{
				buf[j] = input[j][i];
			}
			performSynthesis(buf, out, i*GCConstants.BANDS);
		}
	}

	private function performSynthesis(input : Vector<Float>, out : Vector<Float>, outOff : Int)
	{
		var kk : Int = IntDivision.intDiv(GCConstants.NPQFTAPS, (2*GCConstants.BANDS));
		//int i, n, k;
		var acc : Float;

		for (n in 0...IntDivision.intDiv(GCConstants.BANDS, 2))
		{
			for (k in 0...(2 * kk - 1))
			{
				tmp1[n][k] = tmp1[n][k+1];
				tmp2[n][k] = tmp2[n][k+1];
			}
		}

		for (n in 0...IntDivision.intDiv(GCConstants.BANDS, 2))
		{
			acc = 0.0;
			for (i in 0...GCConstants.BANDS)
			{
				acc += PQFTables.COEFS_Q0[n][i]*input[i];
			}
			tmp1[n][2*kk-1] = acc;

			acc = 0.0;
			for (i in 0...GCConstants.BANDS)
			{
				acc += PQFTables.COEFS_Q1[n][i]*input[i];
			}
			tmp2[n][2*kk-1] = acc;
		}

		for (n in 0...IntDivision.intDiv(GCConstants.BANDS, 2))
		{
			acc = 0.0;
			for (k in 0...kk)
			{
				acc += PQFTables.COEFS_T0[n][k]*tmp1[n][2*kk-1-2*k];
			}
			for (k in 0...kk)
			{
				acc += PQFTables.COEFS_T1[n][k]*tmp2[n][2*kk-2-2*k];
			}
			out[outOff+n] = acc;

			acc = 0.0;
			for (k in 0...kk)
			{
				acc += PQFTables.COEFS_T0[GCConstants.BANDS-1-n][k]*tmp1[n][2*kk-1-2*k];
			}
			for (k in 0...kk)
			{
				acc -= PQFTables.COEFS_T1[GCConstants.BANDS-1-n][k]*tmp2[n][2*kk-2-2*k];
			}
			out[outOff+GCConstants.BANDS-1-n] = acc;
		}
	}	
}