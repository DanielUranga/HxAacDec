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
	
package impl.filterbank;
import flash.Vector;
import impl.VectorTools;
import impl.IntDivision;

class FFT 
{

	private var length : Int;
	private var roots : Array<Array<Float>>;
	private var rev : Vector<Vector<Float>>;
	private var a : Vector<Float>;
	private var b : Vector<Float>;
	private var c : Vector<Float>;
	private var d : Vector<Float>;
	private var e1 : Vector<Float>;
	private var e2 : Vector<Float>;
	
	public function new(length : Int)
	{
		this.length = length;
		switch(length)
		{
			case 64:
				roots = FFTTables.FFT_TABLE_64;
			case 512:
				roots = FFTTables.FFT_TABLE_512;
			case 60:
				roots = FFTTables.FFT_TABLE_60;
			case 480:
				roots = FFTTables.FFT_TABLE_480;
			default:
				throw ("unexpected FFT length: "+length);
		}
		//processing buffers
		rev = VectorTools.newMatrixVectorF(length, 2);
		a = new Vector<Float>(2);
		b = new Vector<Float>(2);
		c = new Vector<Float>(2);
		d = new Vector<Float>(2);
		e1 = new Vector<Float>(2);
		e2 = new Vector<Float>(2);
	}

	public function process(input : Vector<Vector<Float>>, forward : Bool)
	{
		var imOff : Int = (forward ? 2 : 1);
		var scale : Int = (forward ? length: 1);
		//bit-reversal
		var ii : Int = 0;
		for (i in 0...length)
		{
			rev[i][0] = input[ii][0];
			rev[i][1] = input[ii][1];
			var k : Int = length>>1;
			while (ii >= k && k > 0)
			{
				ii -= k;
				k >>= 1;
			}
			ii += k;
		}
		for (i in 0...length)
		{
			input[i][0] = rev[i][0];
			input[i][1] = rev[i][1];
		}
		//bottom base-4 round
		var i : Int = 0;
		while (i < length)
		{
			a[0] = input[i][0]+input[i+1][0];
			a[1] = input[i][1]+input[i+1][1];
			b[0] = input[i+2][0]+input[i+3][0];
			b[1] = input[i+2][1]+input[i+3][1];
			c[0] = input[i][0]-input[i+1][0];
			c[1] = input[i][1]-input[i+1][1];
			d[0] = input[i+2][0]-input[i+3][0];
			d[1] = input[i+2][1]-input[i+3][1];
			input[i][0] = a[0]+b[0];
			input[i][1] = a[1]+b[1];
			input[i+2][0] = a[0]-b[0];
			input[i+2][1] = a[1]-b[1];
			e1[0] = c[0]-d[1];
			e1[1] = c[1]+d[0];
			e2[0] = c[0]+d[1];
			e2[1] = c[1]-d[0];
			if (forward)
			{
				input[i+1][0] = e2[0];
				input[i+1][1] = e2[1];
				input[i+3][0] = e1[0];
				input[i+3][1] = e1[1];
			}
			else
			{
				input[i+1][0] = e1[0];
				input[i+1][1] = e1[1];
				input[i+3][0] = e2[0];
				input[i+3][1] = e2[1];
			}
			i += 4;
		}
		//iterations from bottom to top
		var shift : Int;
		var m : Int;
		var km : Int;
		var rootRe : Float;
		var rootIm : Float;
		var zRe : Float;
		var zIm : Float;
		i = 4;
		while (i < length)
		{
			shift = i<<1;
			m = IntDivision.intDiv(length,shift);
			var j : Int = 0;
			while (j < length)
			{
				for (k in 0...i)
				{
					km = k*m;
					rootRe = roots[km][0];
					rootIm = roots[km][imOff];
					zRe = input[i+j+k][0]*rootRe-input[i+j+k][1]*rootIm;
					zIm = input[i + j + k][0] * rootIm + input[i + j + k][1] * rootRe;
					
					input[i+j+k][0] = (input[j+k][0]-zRe)*scale;
					input[i+j+k][1] = (input[j+k][1]-zIm)*scale;
					input[j+k][0] = (input[j+k][0]+zRe)*scale;
					input[j+k][1] = (input[j+k][1]+zIm)*scale;
				}
				j += shift;
			}
			i <<= 1;
		}
	}
	
}