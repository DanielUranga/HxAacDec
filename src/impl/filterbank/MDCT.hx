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

class MDCT 
{
	
	private var N : Int;
	private var N2 : Int;
	private var N4 : Int;
	private var N8 : Int;
	private var sincos : Array<Array<Float>>;
	private var fft : FFT;
	private var buf : Vector<Vector<Float>>;
	private var tmp : Vector<Float>;

	public function new(length : Int)
	{
		N = length;
		N2 = length>>1;
		N4 = length>>2;
		N8 = length>>3;
		switch(length)
		{
			case 2048:
				sincos = MDCTTables.MDCT_TABLE_2048;
			case 256:
				sincos = MDCTTables.MDCT_TABLE_128;
			case 1920:
				sincos = MDCTTables.MDCT_TABLE_1920;
			case 240:
				sincos = MDCTTables.MDCT_TABLE_240;
			default:
				throw("unsupported MDCT length: "+length);
		}
		fft = new FFT(N4);
		buf = VectorTools.newMatrixVectorF(N4,2);
		tmp = new Vector<Float>(2);
	}

	public function process(input : Vector<Float>, inOff : Int, out : Vector<Float>, outOff : Int)
	{
		var k : Int;
		//pre-IFFT complex multiplication
		for (k in 0...N4)
		{
			buf[k][1] = (input[inOff+2*k]*sincos[k][0])+(input[inOff+N2-1-2*k]*sincos[k][1]);
			buf[k][0] = (input[inOff+N2-1-2*k]*sincos[k][0])-(input[inOff+2*k]*sincos[k][1]);
		}
		//complex IFFT, non-scaling
		fft.process(buf, false);
		//post-IFFT complex multiplication
		for (k in 0...N4)
		{
			tmp[0] = buf[k][0];
			tmp[1] = buf[k][1];
			buf[k][1] = (tmp[1]*sincos[k][0])+(tmp[0]*sincos[k][1]);
			buf[k][0] = (tmp[0]*sincos[k][0])-(tmp[1]*sincos[k][1]);
		}
		//reordering
		var k : Int = 0;
		while (k < N8)
		{
			out[outOff + 2 * k] = buf[N8 + k][1];
			out[outOff + 2 + 2 * k] = buf[N8 + 1 + k][1];
			out[outOff + 1 + 2 * k] = -buf[N8 - 1 - k][0];
			out[outOff + 3 + 2 * k] = -buf[N8 - 2 - k][0];
			out[outOff + N4 + 2 * k] = buf[k][0];
			out[outOff + N4 + 2 + 2 * k] = buf[1 + k][0];
			out[outOff + N4 + 1 + 2 * k] = -buf[N4 - 1 - k][1];
			out[outOff + N4 + 3 + 2 * k] = -buf[N4 - 2 - k][1];
			out[outOff + N2 + 2 * k] = buf[N8 + k][0];
			out[outOff + N2 + 2 + 2 * k] = buf[N8 + 1 + k][0];
			out[outOff + N2 + 1 + 2 * k] = -buf[N8 - 1 - k][1];
			out[outOff + N2 + 3 + 2 * k] = -buf[N8 - 2 - k][1];
			out[outOff + N2 + N4 + 2 * k] = -buf[k][1];
			out[outOff + N2 + N4 + 2 + 2 * k] = -buf[1 + k][1];
			out[outOff + N2 + N4 + 1 + 2 * k] = buf[N4 - 1 - k][0];
			out[outOff + N2 + N4 + 3 + 2 * k] = buf[N4 - 2 - k][0];
			k += 2;
		}
	}

	public function processForward(input : Vector<Float>, out : Vector<Float>)
	{
		var n, k : Int;
		//pre-FFT complex multiplication
		for (k in 0...N8)
		{
			n = k<<1;
			tmp[0] = input[N-N4-1-n]+input[N-N4+n];
			tmp[1] = input[N4+n]-input[N4-1-n];
			buf[k][0] = (tmp[0]*sincos[k][0])+(tmp[1]*sincos[k][1]);
			buf[k][1] = (tmp[1]*sincos[k][0])-(tmp[0]*sincos[k][1]);
			buf[k][0] = buf[k][0]*N;
			buf[k][1] = buf[k][1]*N;
			tmp[0] = input[N2-1-n]-input[n];
			tmp[1] = input[N2+n]+input[N-1-n];
			buf[k+N8][0] = (tmp[0]*sincos[k+N8][0])+(tmp[1]*sincos[k+N8][1]);
			buf[k+N8][1] = (tmp[1]*sincos[k+N8][0])-(tmp[0]*sincos[k+N8][1]);
			buf[k+N8][0] = buf[k+N8][0]*N;
			buf[k+N8][1] = buf[k+N8][1]*N;
		}
		//complex FFT, non-scaling
		fft.process(buf, true);
		//post-FFT complex multiplication
		for (k in 0...N4)
		{
			n = k<<1;
			tmp[0] = (buf[k][0]*sincos[k][0])+(buf[k][1]*sincos[k][1]);
			tmp[1] = (buf[k][1]*sincos[k][0])-(buf[k][0]*sincos[k][1]);
			out[n] = -tmp[0];
			out[N2-1-n] = tmp[1];
			out[N2+n] = -tmp[1];
			out[N-1-n] = tmp[0];
		}
	}
	
}