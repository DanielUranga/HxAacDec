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
	
package impl.huffman;

import flash.Vector;
import impl.BitStream;
import impl.error.BitsBuffer;
import impl.IntMath;
import impl.VectorTools;

class Huffman 
{
	
	private static inline var PAIR_LEN : Int = 2;
	private static inline var QUAD_LEN : Int = 4;
	private var BITS : Vector<Int>;
	private var VCB11_LAV : Vector<Int>;
	
	private var hcbSf : Vector<Vector<Int>>;
	private var twoStepCodebooks : Vector<Vector<Vector<Vector<Int>>>>;
	private var binaryCodeBooks : Vector<Vector<Vector<Int>>>;
	private var unsignedCodeBook : Vector<Bool>;
	
	public function new()
	{
		//BITS = [0, 5, 5, 0, 5, 0, 5, 0, 5, 0, 6, 5];
		BITS = new Vector<Int>(12);
		BITS[0] = 0; BITS[1] = 5; BITS[2] = 5; BITS[3] = 0;
		BITS[4] = 5; BITS[5] = 0; BITS[6] = 5; BITS[7] = 0;
		BITS[8] = 5; BITS[9] = 0; BITS[10] = 6; BITS[11] = 5;
		
		//VCB11_LAV = [16, 31, 47, 63, 95, 127, 159, 191, 223, 255, 319, 383, 511, 767, 1023, 2047];
		VCB11_LAV = new Vector<Int>(16);
		VCB11_LAV[0] = 16; VCB11_LAV[1] = 31; VCB11_LAV[2] = 47; VCB11_LAV[3] = 63;
		VCB11_LAV[4] = 95; VCB11_LAV[5] = 127; VCB11_LAV[6] = 159; VCB11_LAV[7] = 191;
		VCB11_LAV[8] = 223; VCB11_LAV[9] = 255; VCB11_LAV[10] = 319; VCB11_LAV[11] = 383;
		VCB11_LAV[12] = 511; VCB11_LAV[13] = 767; VCB11_LAV[14] = 1023; VCB11_LAV[15] = 2047;
		
		hcbSf = VectorTools.newMatrixVectorI(HCB_SF.HCB_SF.HCB_SF.length, HCB_SF.HCB_SF.HCB_SF[0].length);
		for (i in 0...HCB_SF.HCB_SF.HCB_SF.length)
		{
			for ( j in 0...HCB_SF.HCB_SF.HCB_SF[0].length )
			{
				hcbSf[i][j] = HCB_SF.HCB_SF.HCB_SF[i][j];
			}
		}
		
		twoStepCodebooks = new Vector<Vector<Vector<Vector<Int>>>>(Codebooks.TWO_STEP_CODEBOOKS.length);
		for ( a in 0...Codebooks.TWO_STEP_CODEBOOKS.length )
		{
			if ( Codebooks.TWO_STEP_CODEBOOKS[a] != null )
			{
				twoStepCodebooks[a] = new Vector<Vector<Vector<Int>>>(Codebooks.TWO_STEP_CODEBOOKS[a].length);				
				for ( b in 0...Codebooks.TWO_STEP_CODEBOOKS[a].length )
				{
					if ( Codebooks.TWO_STEP_CODEBOOKS[a][b] != null )
					{
						twoStepCodebooks[a][b] = new Vector<Vector<Int>>(Codebooks.TWO_STEP_CODEBOOKS[a][b].length);						
						for ( c in 0...Codebooks.TWO_STEP_CODEBOOKS[a][b].length )
						{
							if ( Codebooks.TWO_STEP_CODEBOOKS[a][b][c] != null )
							{
								twoStepCodebooks[a][b][c] = new Vector<Int>(Codebooks.TWO_STEP_CODEBOOKS[a][b][c].length);
								for ( d in 0...Codebooks.TWO_STEP_CODEBOOKS[a][b][c].length )
								{
									twoStepCodebooks[a][b][c][d] = Codebooks.TWO_STEP_CODEBOOKS[a][b][c][d];
								}
							}
						}
					}
				}
			}
		}
		
		binaryCodeBooks = new Vector<Vector<Vector<Int>>>(Codebooks.BINARY_CODEBOOKS.length);
		for ( a in 0...Codebooks.BINARY_CODEBOOKS.length )
		{
			if ( Codebooks.BINARY_CODEBOOKS[a] != null )
			{
				binaryCodeBooks[a] = new Vector<Vector<Int>>(Codebooks.BINARY_CODEBOOKS[a].length);
				for ( b in 0...Codebooks.BINARY_CODEBOOKS[a].length )
				{
					binaryCodeBooks[a][b] = new Vector<Int>(Codebooks.BINARY_CODEBOOKS[a][b].length);
					for ( c in 0...Codebooks.BINARY_CODEBOOKS[a][b].length )
					{
						binaryCodeBooks[a][b][c] = Codebooks.BINARY_CODEBOOKS[a][b][c];
					}
				}
			}
		}
		
		unsignedCodeBook = new Vector<Bool>(Codebooks.UNSIGNED_CODEBOOK.length);
		for ( a in 0...Codebooks.UNSIGNED_CODEBOOK.length )
			unsignedCodeBook[a] = Codebooks.UNSIGNED_CODEBOOK[a];
		
	}
	
	public function decodeScaleFactor(input : BitStream) : Int
	{
		var offset : Int = 0;
		var b : Int;
		while (hcbSf[offset][1]!=0)
		{
			b = input.readBit();
			offset += hcbSf[offset][b];
			if (offset > 240)
				throw("scale factor out of range: "+offset);
		}
		return hcbSf[offset][0];
	}
	
	private inline function signBits(input : BitStream, data : Vector<Int>, off : Int, len : Int)
	{
		for (i in 0...len)
		{
			if (data[off + i] != 0)
			{
				if (input.readBool())
				{
					data[off+i] = -data[off+i];
				}
			}
		}
	}
	
	private function getEscape(input : BitStream, s : Int) : Int
	{
		var ret : Int;
		if (IntMath.abs(s) != 16)
			ret = s;
		else
		{
			var neg : Bool = s<0;
			var i : Int = 4;
			while (input.readBool())
			{
				i++;
			}
			var j : Int = input.readBits(i)|(1<<i);
			ret = (neg ? -j : j);
		}
		return ret;
	}
	
	private function decode2StepQuad(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		//var TABLE1 : Vector<Vector<Int>> = twoStepCodebooks[cb][0];
		//var TABLE2 : Vector<Vector<Int>> = twoStepCodebooks[cb][1];
		var cw : Int = input.peekBits(BITS[cb]);
		var offset : Int = twoStepCodebooks[cb][0][cw][0];
		var extraBits : Int = twoStepCodebooks[cb][0][cw][1];
		if (extraBits == 0)
		{
			input.skipBits(twoStepCodebooks[cb][1][offset][0]);
		}
		else
		{
			input.skipBits(BITS[cb]);
			offset += input.peekBits(extraBits);
			input.skipBits(twoStepCodebooks[cb][1][offset][0]-BITS[cb]);
		}
		if (offset > cast(twoStepCodebooks[cb][1].length, Int))
		{
			throw("invalid offset in scalefactor decoding: " + offset + ", codebook: " + cb);
		}
		data[off] = twoStepCodebooks[cb][1][offset][1];
		data[off+1] = twoStepCodebooks[cb][1][offset][2];
		data[off+2] = twoStepCodebooks[cb][1][offset][3];
		data[off+3] = twoStepCodebooks[cb][1][offset][4];
	}
	
	private inline function decode2StepQuadSign(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		decode2StepQuad(cb, input, data, off);
		signBits(input, data, off, QUAD_LEN);
	}
	
	private function decode2StepPair(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		//var TABLE1 : Vector<Vector<Int>> = twoStepCodebooks[cb][0];
		//var TABLE2 : Vector<Vector<Int>> = twoStepCodebooks[cb][1];		
		var cw : Int = input.peekBits(BITS[cb]);
		var offset : Int = twoStepCodebooks[cb][0][cw][0];
		var extraBits : Int = twoStepCodebooks[cb][0][cw][1];		
		if (extraBits == 0)
		{
			input.skipBits(twoStepCodebooks[cb][1][offset][0]);
		}
		else
		{
			input.skipBits(BITS[cb]);
			offset += input.peekBits(extraBits);
			input.skipBits(twoStepCodebooks[cb][1][offset][0] - BITS[cb]);
		}
		if (offset > cast(twoStepCodebooks[cb][1].length, Int))
		{
			throw("invalid offset in scalefactor decoding: " + offset + ", codebook: " + cb);
		}
		data[off] = twoStepCodebooks[cb][1][offset][1];
		data[off+1] = twoStepCodebooks[cb][1][offset][2];
	}
	
	private inline function decode2StepPairSign(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		decode2StepPair(cb, input, data, off);
		signBits(input, data, off, PAIR_LEN);		
	}
	
	private function decodeBinaryQuad(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		//var TABLE : Array<Array<Int>> = Codebooks.BINARY_CODEBOOKS[cb];
		//binaryCodeBooks = new Vector<Vector<Vector<Int>>>(Codebooks.BINARY_CODEBOOKS.length);
		var TABLE : Vector<Vector<Int>> = binaryCodeBooks[cb];
		var offset : Int = 0;
		var b : Int;
		while (TABLE[offset][0] == 0)
		{
			b = input.readBit();
			offset += TABLE[offset][b+1];
		}
		if (offset > Std.int(TABLE.length))
			throw("invalid offset in scalefactor decoding: "+offset+", codebook: "+cb);
		data[off] = TABLE[offset][1];
		data[off+1] = TABLE[offset][2];
		data[off+2] = TABLE[offset][3];
		data[off+3] = TABLE[offset][4];
	}
	
	private inline function decodeBinaryQuadSign(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		decodeBinaryQuad(cb, input, data, off);
		signBits(input, data, off, QUAD_LEN);
	}
	
	private function decodeBinaryPair(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		//var TABLE : Array<Array<Int>> = Codebooks.BINARY_CODEBOOKS[cb];
		var TABLE : Vector<Vector<Int>> = binaryCodeBooks[cb];
		var offset : Int = 0;
		var b : Int;
		while (TABLE[offset][0] == 0)
		{
			b = input.readBit();
			offset += TABLE[offset][b+1];
		}
		if (offset > Std.int(TABLE.length))
		{
			throw("invalid offset in scalefactor decoding: " + offset + ", codebook: " + cb);
		}
		data[off] = TABLE[offset][1];
		data[off+1] = TABLE[offset][2];
	}
	
	private function decodeBinaryPairSign(cb : Int, input : BitStream, data : Vector<Int>, off : Int)
	{
		decodeBinaryPair(cb, input, data, off);
		signBits(input, data, off, PAIR_LEN);
	}
	
	public function decodeSpectralData(input : BitStream, cb : Int, data : Vector<Int>, off : Int)
	{
		switch(cb)
		{
			case 1, 2:
				decode2StepQuad(cb, input, data, off);
			case 3:
				decodeBinaryQuadSign(cb, input, data, off);
			case 4:
				decode2StepQuadSign(cb, input, data, off);
			case 5:
				decodeBinaryPair(cb, input, data, off);
			case 6:
				decode2StepPair(cb, input, data, off);
			case 7, 9:
				decodeBinaryPairSign(cb, input, data, off);
			case 8, 10:
				decode2StepPairSign(cb, input, data, off);
			case 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31:
			{
				decode2StepPairSign(11, input, data, off);
				data[off] = getEscape(input, data[off]);
				data[off+1] = getEscape(input, data[off+1]);
				//error resilience
				if (cb > 11)
					checkLAV(cb, data, off);
			}
			default:
				throw ("unknown huffman codebook: "+cb);
		}
	}
	
	private inline function checkLAV(cb : Int, data : Vector<Int>, off : Int)
	{
		if (cb>=16 && cb<=31)
		{
			var max : Int = VCB11_LAV[cb - 16];
			if ((IntMath.abs(data[off]) > max) || (IntMath.abs(data[off + 1]) > max))
			{
				data[0] = 0;
				data[1] = 0;
			}
		}
	}
	
	/**
	 * special version for error resilience:
	 * - does not read from a BitStream but a BitsBuffer
	 * - keeps track of the bits decoded and returns the number of bits remaining
	 * - does not read more than in.len, return -1 if codeword would be longer
	 */
	public function decodeSpectralDataER(input : BitsBuffer, cb : Int, data : Vector<Int>, off : Int)
	{
		var cw : Int;
		var offset : Int = 0;
		var extraBits : Int;
		var i : Int;
		var vcb11 : Int = 0;
		//var table1 : Vector<Vector<Int>>;
		//var table2 : Vector<Vector<Int>>;
		var binTable : Vector<Vector<Int>>;
		switch(cb)
		{
			//2-step method for data quadruples
			case 1, 2, 4:
			{
				//table1 = twoStepCodebooks[cb][0];
				//table2 = twoStepCodebooks[cb][1];
				cw = input.showBits(BITS[cb]);
				offset = twoStepCodebooks[cb][0][cw][0];
				extraBits = twoStepCodebooks[cb][1][cw][1];

				if (extraBits != 0)
				{
					if(input.flushBits(BITS[cb])) return -1;
					offset += input.showBits(extraBits);
					if(input.flushBits(twoStepCodebooks[cb][1][offset][0]-BITS[cb])) return -1;
				}
				else 
				{
					if(input.flushBits(twoStepCodebooks[cb][1][offset][0])) return -1;
				}

				data[0] = twoStepCodebooks[cb][1][offset][1];
				data[1] = twoStepCodebooks[cb][1][offset][2];
				data[2] = twoStepCodebooks[cb][1][offset][3];
				data[3] = twoStepCodebooks[cb][1][offset][4];
			}

			//2-step method for data pairs
			case 6, 8, 10, 11, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31:
			{
				if (cb >= 16)
				{
					vcb11 = cb;
					cb = 11;
				}

				//table1 = twoStepCodebooks[cb][0];
				//table2 = twoStepCodebooks[cb][1];

				cw = input.showBits(BITS[cb]);
				offset = twoStepCodebooks[cb][0][cw][0];
				extraBits = twoStepCodebooks[cb][0][cw][1];

				if (extraBits != 0)
				{
					if(input.flushBits(BITS[cb])) return -1;
					offset += input.showBits(extraBits);
					if(input.flushBits(twoStepCodebooks[cb][1][offset][0]-BITS[cb])) return -1;
				}
				else
				{
					if(input.flushBits(twoStepCodebooks[cb][1][offset][0])) return -1;
				}
				data[0] = twoStepCodebooks[cb][1][offset][1];
				data[1] = twoStepCodebooks[cb][1][offset][2];
			}

			//binary search
			case 3, 5, 7, 9:
			{
				binTable = binaryCodeBooks[cb];

				while (binTable[offset][0] == 0)
				{
					var b : Int = input.getBit();
					if(b==-1) return -1;
					offset += binTable[offset][b+1];
				}

				data[0] = binTable[offset][1];
				data[1] = binTable[offset][2];
				if (cb == 3)
				{
					//quad table
					data[2] = binTable[offset][3];
					data[3] = binTable[offset][4];
				}
			}
		}

		//decode sign bits
		if (unsignedCodeBook[cb])
		{
			i = 0;
			while (i < ((cb < HCB.FIRST_PAIR_HCB) ? QUAD_LEN : PAIR_LEN))
			{
				if (data[i] != 0)
				{
					var b : Int = input.getBit();
					if(b==-1) return -1;
					else if(b!=0) data[i] = -data[i];
				}
				i++;
			}
		}

		//decode huffman escape bits
		if ((cb == HCB.ESCAPE_HCB) || (cb >= 16))
		{
			var neg : Bool;
			var b : Int;
			var x : Int;
			var j : Int;
			for (k in 0...2)
			{
				if ((data[k] == 16) || (data[k] == -16))
				{
					neg = data[k]<0;

					i = 4;
					do {
						b = input.getBit();
						if(b==-1) return -1;
						//else if (b == 0) break;
						i++;
					} while (b == 0);

					x = input.getBits(i);
					if(x==-1) return -1;
					j = x+(1<<i);
					data[k] = (neg ? -j : j);
				}
			}

			if(vcb11!=0) checkLAV(cb, data, off);
		}
		return input.getLength();
	}
	
}