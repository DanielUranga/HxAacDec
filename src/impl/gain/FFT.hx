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

class FFT 
{

	private static var FFT_TABLE_128 : Array<Array<Float>> = [
		[1.0, -0.0],
		[0.99879545, -0.049067676],
		[0.9951847, -0.09801714],
		[0.9891765, -0.14673047],
		[0.98078525, -0.19509032],
		[0.97003126, -0.24298018],
		[0.95694035, -0.29028466],
		[0.94154406, -0.33688986],
		[0.9238795, -0.38268343],
		[0.9039893, -0.42755508],
		[0.8819213, -0.47139674],
		[0.8577286, -0.51410276],
		[0.8314696, -0.55557024],
		[0.8032075, -0.5956993],
		[0.77301043, -0.6343933],
		[0.7409511, -0.671559],
		[0.70710677, -0.70710677],
		[0.671559, -0.7409511],
		[0.6343933, -0.77301043],
		[0.5956993, -0.8032075],
		[0.55557024, -0.8314696],
		[0.51410276, -0.8577286],
		[0.47139674, -0.8819213],
		[0.42755508, -0.9039893],
		[0.38268343, -0.9238795],
		[0.33688986, -0.94154406],
		[0.29028466, -0.95694035],
		[0.24298018, -0.97003126],
		[0.19509032, -0.98078525],
		[0.14673047, -0.9891765],
		[0.09801714, -0.9951847],
		[0.049067676, -0.99879545],
		[6.123234E-17, -1.0],
		[-0.049067676, -0.99879545],
		[-0.09801714, -0.9951847],
		[-0.14673047, -0.9891765],
		[-0.19509032, -0.98078525],
		[-0.24298018, -0.97003126],
		[-0.29028466, -0.95694035],
		[-0.33688986, -0.94154406],
		[-0.38268343, -0.9238795],
		[-0.42755508, -0.9039893],
		[-0.47139674, -0.8819213],
		[-0.51410276, -0.8577286],
		[-0.55557024, -0.8314696],
		[-0.5956993, -0.8032075],
		[-0.6343933, -0.77301043],
		[-0.671559, -0.7409511],
		[-0.70710677, -0.70710677],
		[-0.7409511, -0.671559],
		[-0.77301043, -0.6343933],
		[-0.8032075, -0.5956993],
		[-0.8314696, -0.55557024],
		[-0.8577286, -0.51410276],
		[-0.8819213, -0.47139674],
		[-0.9039893, -0.42755508],
		[-0.9238795, -0.38268343],
		[-0.94154406, -0.33688986],
		[-0.95694035, -0.29028466],
		[-0.97003126, -0.24298018],
		[-0.98078525, -0.19509032],
		[-0.9891765, -0.14673047],
		[-0.9951847, -0.09801714],
		[-0.99879545, -0.049067676]
	];
	private static var FFT_TABLE_16 : Array<Array<Float>> = [
		[1.0, -0.0],
		[0.9238795, -0.38268343],
		[0.70710677, -0.70710677],
		[0.38268343, -0.9238795],
		[6.123234E-17, -1.0],
		[-0.38268343, -0.9238795],
		[-0.70710677, -0.70710677],
		[-0.9238795, -0.38268343]
	];

	public static function process(input : Vector<Vector<Float>>, n : Int)
	{
		var ln : Int = Math.round(Math.log(n)/Math.log(2));
		var table : Array<Array<Float>> = (n==128) ? FFT_TABLE_128 : FFT_TABLE_16;

		//bit-reversal
		//final float[][] rev = new float[n][2];
		var rev : Vector<Vector<Float>> = VectorTools.newMatrixVectorF(n, 2);
		var ii : Int = 0;
		for (i in 0...n)
		{
			rev[i][0] = input[ii][0];
			rev[i][1] = input[ii][1];
			var k : Int = n>>1;
			while (ii >= k && k > 0)
			{
				ii -= k;
				k >>= 1;
			}
			ii += k;
		}
		for (i in 0...n)
		{
			input[i][0] = rev[i][0];
			input[i][1] = rev[i][1];
		}

		//calculation
		var blocks : Int = IntDivision.intDiv(n, 2);
		var size : Int = 2;
		var l : Int;
		var k0 : Int;
		var k1 : Int;
		var size2 : Int;
		var a : Vector<Float> = new Vector<Float>(2);
		for (i in 0...ln)
		{
			size2 = IntDivision.intDiv(size, 2);
			k0 = 0;
			k1 = size2;
			for (j in 0...blocks)
			{
				l = 0;
				for (k in 0...size2)
				{
					a[0] = input[k1][0]*table[l][0]-input[k1][1]*table[l][1];
					a[1] = input[k1][0]*table[l][1]+input[k1][1]*table[l][0];
					input[k1][0] = input[k0][0]-a[0];
					input[k1][1] = input[k0][1]-a[1];
					input[k0][0] += a[0];
					input[k0][1] += a[1];
					l += blocks;
					k0++;
					k1++;
				}
				k0 += size2;
				k1 += size2;
			}
			blocks = IntDivision.intDiv(blocks, 2);
			size = size*2;
		}
	}
	
}