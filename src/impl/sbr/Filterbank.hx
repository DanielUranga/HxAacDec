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
import impl.sbr.FilterbankTables;

class Filterbank 
{
	
	private static var FFT_LENGTH  : Int = 32;
	private var tmp : Vector<Float>;
	
	public function new()
	{
		tmp = new Vector<Float>(2);
	}

	//complex DCT-IV of length 64 without reordering
	public function computeDCT4Kernel(input : Vector<Vector<Float>>, out : Vector<Vector<Float>>)
	{
		var f  : Float;
		var i : Int;
		var iRev : Int;
		//Step 1: modulate
		for (i in 0...32)
		{
			tmp[0] = input[i][0];
			tmp[1] = input[i][1];
			f = (tmp[0]+tmp[1])*FilterbankTables.DCT4_64_TABLE[i];
			input[i][0] = (tmp[1]*FilterbankTables.DCT4_64_TABLE[i+64])+f;
			input[i][1] = (tmp[0]*FilterbankTables.DCT4_64_TABLE[i+32])+f;
		}
		//Step 2: FFT, but with output in bit reverse order
		computeFFT(input);
		//Step 3: modulate + bitreverse reordering
		for (i in 0...16)
		{
			iRev = FilterbankTables.BIT_REVERSE_TABLE[i];
			tmp[0] = input[iRev][0];
			tmp[1] = input[iRev][1];
			f = (tmp[0]+tmp[1])*FilterbankTables.DCT4_64_TABLE[i+3*32];
			out[i][0] = (tmp[1]*FilterbankTables.DCT4_64_TABLE[i+5*32])+f;
			out[i][1] = (tmp[0]*FilterbankTables.DCT4_64_TABLE[i+4*32])+f;
		}
		out[16][1] = (input[1][1]-input[1][0])*FilterbankTables.DCT4_64_TABLE[16+3*32];
		out[16][0] = (input[1][0]+input[1][1])*FilterbankTables.DCT4_64_TABLE[16+3*32];
		for (i in 17...32)
		{
			iRev = FilterbankTables.BIT_REVERSE_TABLE[i];
			tmp[0] = input[iRev][0];
			tmp[1] = input[iRev][1];
			f = (tmp[0]+tmp[1])*FilterbankTables.DCT4_64_TABLE[i+3*32];
			out[i][0] = (tmp[1]*FilterbankTables.DCT4_64_TABLE[i+5*32])+f;
			out[i][1] = (tmp[0]*FilterbankTables.DCT4_64_TABLE[i+4*32])+f;
		}
	}
	
	//32-point FFT: 144 multiplications, 400 additions
	private function computeFFT(input : Vector<Vector<Float>>)
	{
		var re1 : Float;
		var im1 : Float;
		var re2 : Float;
		var im2 : Float;
		var i : Int;
		var j : Int;
		var z : Int;
		//stage 1
		for (i in 0...16)
		{
			re1 = input[i][0];
			im1 = input[i][1];
			z = i+16;
			re2 = input[z][0];
			im2 = input[z][1];
			tmp[0] = FilterbankTables.FFT_TABLE[i][0];
			tmp[1] = FilterbankTables.FFT_TABLE[i][1];
			re1 -= re2;
			im1 -= im2;
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = (re1*tmp[0])-(im1*tmp[1]);
			input[z][1] = (re1*tmp[1])+(im1*tmp[0]);
		}
		//stage 2
		var index : Int = 0;
		for (j in 0...8)
		{
			tmp[0] = FilterbankTables.FFT_TABLE[index][0];
			tmp[1] = FilterbankTables.FFT_TABLE[index][1];
			index += 2;
			i = j;
			re1 = input[i][0];
			im1 = input[i][1];
			z = i+8;
			re2 = input[z][0];
			im2 = input[z][1];
			re1 -= re2;
			im1 -= im2;
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = (re1*tmp[0])-(im1*tmp[1]);
			input[z][1] = (re1*tmp[1])+(im1*tmp[0]);
			i = j+16;
			re1 = input[i][0];
			im1 = input[i][1];
			z = i+8;
			re2 = input[z][0];
			im2 = input[z][1];
			re1 -= re2;
			im1 -= im2;
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = (re1*tmp[0])-(im1*tmp[1]);
			input[z][1] = (re1*tmp[1])+(im1*tmp[0]);
		}
		//stage 3
		var i : Int = 0;
		while(i<FFT_LENGTH)
		{
			z = i+4;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = re1-re2;
			input[z][1] = im1 - im2;
			i += 8;
		}
		tmp[0] = FilterbankTables.FFT_TABLE[4][0];
		i = 1;
		while(i<FFT_LENGTH)
		{
			z = i+4;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			re1 -= re2;
			im1 -= im2;
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = (re1+im1)*tmp[0];
			input[z][1] = (im1 - re1) * tmp[0];
			i += 8;
		}
		i = 2;
		while(i<FFT_LENGTH)
		{
			z = i+4;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = im1-im2;
			input[z][1] = re2 - re1;
			i += 8;
		}
		tmp[0] = FilterbankTables.FFT_TABLE[12][0];
		i = 3;
		while(i<FFT_LENGTH)
		{
			z = i+4;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			re1 -= re2;
			im1 -= im2;
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = (re1-im1)*tmp[0];
			input[z][1] = (re1 + im1) * tmp[0];
			i += 8;
		}
		//stage 4
		i = 0;
		while(i<FFT_LENGTH)
		{
			z = i+2;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = re1-re2;
			input[z][1] = im1 - im2;
			i += 4;
		}
		i = 1;
		while(i<FFT_LENGTH)
		{
			z = i+2;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = im1-im2;
			input[z][1] = re2 - re1;
			i += 4;
		}
		//stage 5
		i = 0;
		while(i<FFT_LENGTH)
		{
			z = i+1;
			re1 = input[i][0];
			im1 = input[i][1];
			re2 = input[z][0];
			im2 = input[z][1];
			input[i][0] += re2;
			input[i][1] += im2;
			input[z][0] = re1-re2;
			input[z][1] = im1 - im2;
			i += 2;
		}
	}
	
}