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
	
package impl.error;
import flash.Vector;
import impl.BitStream;

class BitsBuffer 
{

	public var bufa : Int;
	public var bufb : Int;
	public var len : Int;
	
	public function new() 
	{
		len = 0;
	}
	
	public function getLength() : Int
	{
		return len;
	}
	
	public function showBits(bits : Int) : Int
	{
		if (bits == 0)
			return 0;
		if (len <= 32)
		{
			//huffman_spectral_data_2 needs to read more than may be available,
			//bits maybe > len, deliver 0 than
			if (len >= bits)
				return ((bufa>>(len-bits))&(0xFFFFFFFF>>(32-bits)));
			else
				return ((bufa<<(bits-len))&(0xFFFFFFFF>>(32-bits)));
		}
		else
		{
			if ((len - bits) < 32)
				return ((bufb&(0xFFFFFFFF>>(64-len)))<<(bits-len+32))|(bufa>>(len-bits));
			else
				return ((bufb>>(len-bits-32))&(0xFFFFFFFF>>(32-bits)));
		}
	}
	
	public function flushBits(bits : Int) : Bool
	{
		len -= bits;
		var b : Bool;
		if (len < 0)
		{
			len = 0;
			b = false;
		}
		else
			b = true;
		return b;
	}
	
	public function getBits(n : Int) : Int
	{
		var i : Int = showBits(n);
		if (!flushBits(n))
			i = -1;
		return i;
	}
	
	public function getBit() : Int
	{
		var i : Int = showBits(1);
		if (!flushBits(1))
			i = -1;
		return i;
	}
	
	public function rewindReverse()
	{
		if (len == 0)
			return;
		var i : Array<Int> = HCR.rewindReverse64(bufb, bufa, len);
		bufb = i[0];
		bufa = i[1];
	}
	
	//merge bits of a to b
	public function concatBits(a : BitsBuffer)
	{
		if(a.len==0) return;
		var al : Int = a.bufa;
		var ah : Int = a.bufb;

		var bl : Int;
		var bh : Int;
		if (len > 32)
		{
			//mask off superfluous high b bits
			bl = bufa;
			bh = bufb&((1<<(len-32))-1);
			//left shift a len bits
			ah = al<<(len-32);
			al = 0;
		}
		else 
		{
			bl = bufa&((1<<(len))-1);
			bh = 0;
			ah = (ah<<(len))|(al>>(32-len));
			al = al<<len;
		}

		//merge
		bufa = bl|al;
		bufb = bh|ah;

		len += a.len;
	}

	public function readSegment(segwidth : Int, input : BitStream)
	{
		len = segwidth;

		if (segwidth > 32) 
		{
			bufb = input.readBits(segwidth-32);
			bufa = input.readBits(32);
		}
		else 
		{
			bufa = input.readBits(segwidth);
			bufb = 0;
		}
	}
	
}