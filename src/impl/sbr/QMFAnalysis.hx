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

class QMFAnalysis 
{

	private var filterBank : Filterbank;
	private var x : Vector<Float>;
	private var sum : Vector<Float>;
	private var tmpIn : Vector<Vector<Float>>;
	private var tmpOut : Vector<Vector<Float>>;
	private var xIndex : Int;

	public function new(filterBank : Filterbank, channels : Int)
	{
		this.filterBank = filterBank;
		x = new Vector<Float>(20*channels);
		sum = new Vector<Float>(64);
		//tmpIn = new float[32][2];
		tmpIn = VectorTools.newMatrixVectorF(32, 2);
		//tmpOut = new float[32][2];
		tmpOut = VectorTools.newMatrixVectorF(32, 2);
		xIndex = 0;
	}

	public function performAnalysis32(input : Vector<Float>, out : Vector<Vector<Vector<Float>>>, offset : Int, kx : Int, len : Int)
	{
		var off : Int = 0;
		
		//int n;
		for (l in 0...len)
		{
			//add new samples to input buffer x
			var m : Int = 32 - 1;
			while ( m >= 0 )
			{
				x[xIndex+m] = input[off];
				x[xIndex+m+320] = input[off];
				off++;
				m--;
			}

			//window and summation to create array u
			for (n in 0...64)
			{
				sum[n] = (x[xIndex+n]*FilterbankTables.QMF_C[2*n])
						+(x[xIndex+n+64]*FilterbankTables.QMF_C[2*(n+64)])
						+(x[xIndex+n+128]*FilterbankTables.QMF_C[2*(n+128)])
						+(x[xIndex+n+192]*FilterbankTables.QMF_C[2*(n+192)])
						+(x[xIndex+n+256]*FilterbankTables.QMF_C[2*(n+256)]);
			}

			//update ringbuffer index
			xIndex -= 32;
			if(xIndex<0) xIndex = (320-32);

			//reordering
			tmpIn[31][1] = sum[1];
			tmpIn[0][0] = sum[0];
			for (n in 1...31)
			{
				tmpIn[31-n][1] = sum[n+1];
				tmpIn[n][0] = -sum[64-n];
			}
			tmpIn[0][1] = sum[32];
			tmpIn[31][0] = -sum[33];

			filterBank.computeDCT4Kernel(tmpIn, tmpOut);

			//reordering
			for (n in 0...16)
			{
				if (2 * n + 1 < kx)
				{
					out[l+offset][2*n][0] = 2.0*tmpOut[n][0];
					out[l+offset][2*n][1] = 2.0*tmpOut[n][1];
					out[l+offset][2*n+1][0] = -2.0*tmpOut[31-n][1];
					out[l+offset][2*n+1][1] = -2.0*tmpOut[31-n][0];
				}
				else
				{
					if (2 * n < kx)
					{
						out[l+offset][2*n][0] = 2.0*tmpOut[n][0];
						out[l+offset][2*n][1] = 2.0*tmpOut[n][1];
					}
					else
					{
						out[l+offset][2*n][0] = 0;
						out[l+offset][2*n][1] = 0;
					}
					out[l+offset][2*n+1][0] = 0;
					out[l+offset][2*n+1][1] = 0;
				}
			}			
		}
	}
	
}