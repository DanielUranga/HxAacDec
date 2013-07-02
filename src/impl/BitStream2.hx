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

package impl;
import flash.Memory;
import flash.Vector;
import haxe.io.BytesData;

class BitStream
{

	private static inline var WORD_BITS : Int = 32;
	private static inline var WORD_BYTES : Int = 4;
	private static inline var BYTE_MASK : Int = 0xff;
	//private var buffer : Vector<Int>;
	private var bufferLenght : Int;
	private var pos : Int; //offset in the buffer array
	private var cache : Int; //current 4 bytes, that are read from the buffer
	var bitsCached : Int; //remaining bits in current cache
	var position : Int; //number of total bits read

	public function new( ?data : BytesData )
	{
		reset();
		if ( data != null )
		{
			setData(data);
		}
		else
		{
			bufferLenght = 0;
		}
	}

	public function destroy()
	{
		reset();
	}

	public function setData(data : BytesData)
	{
		/*
		//make the buffer size an integer number of words
		final int size = WORD_BYTES*((data.length+WORD_BYTES-1)/WORD_BYTES);
		//only reallocate if needed
		if(buffer==null||buffer.length!=size) buffer = new byte[size];
		System.arraycopy(data, 0, buffer, 0, data.length);
		*/
		var buffer : BytesData = new BytesData();
		buffer.length = Math.floor(WORD_BYTES * ((data.length + WORD_BYTES - 1) / WORD_BYTES));
		Memory.select(buffer);
		for ( i in 0...data.length )
		{
			Memory.setByte(i, data[i]);
		}
		bufferLenght = data.length;
		reset();
	}

	public function byteAlign()
	{
		var toFlush : Int = bitsCached&7;
		if(toFlush>0) skipBits(toFlush);
	}

	public function reset()
	{
		pos = 0;
		bitsCached = 0;
		cache = 0;
		position = 0;
	}

	public function getPosition()
	{
		return position;
	}

	public function getBitsLeft()
	{
		return 8*(bufferLenght-pos)+bitsCached;
	}

	/**
	 * Reads the next four bytes.
	 * @param peek if true, the stream pointer will not be increased
	 */
	public function readCache(peek : Bool) :Int
	{
		var i : Int;
		if(pos>bufferLenght-WORD_BYTES) throw ("end of stream");
		else i = ((Memory.getByte(pos)&BYTE_MASK)<<24)
					|((Memory.getByte(pos+1)&BYTE_MASK)<<16)
					|((Memory.getByte(pos+2)&BYTE_MASK)<<8)
					|(Memory.getByte(pos+3)&BYTE_MASK);
		if(!peek) pos += WORD_BYTES;
		return i;
	}

	public function readBits(n : Int) : Int
	{
		if(getBitsLeft()<n) throw("invalid data: less than "+n+" bits left, buffer.length="+bufferLenght+", pos="+pos+", bitsLeft="+bitsCached);
		var result : Int;
		if (bitsCached >= n)
		{
			bitsCached -= n;
			result = (cache>>bitsCached)&maskBits(n);
			position += n;
		}
		else
		{
			position += n;
			var c : Int = cache&maskBits(bitsCached);
			var left : Int = n-bitsCached;
			cache = readCache(false);
			bitsCached = WORD_BITS-left;
			result = ((cache>>bitsCached)&maskBits(left))|(c<<left);
		}
		return result;
	}

	public function readBit() : Int
	{
		if(getBitsLeft()<1) throw("invalid data: less than 1 bit left, position: "+position);
		var i : Int;
		if (bitsCached > 0)
		{
			bitsCached--;
			i = (cache>>(bitsCached))&1;
			position++;
		}
		else
		{
			cache = readCache(false);
			bitsCached = WORD_BITS-1;
			position++;
			i = (cache>>bitsCached)&1;
		}
		return i;
	}

	public function readBool() : Bool
	{
		return (readBit()&0x1)!=0;
	}

	public function peekBits(n : Int) : Int
	{
		var ret : Int;
		if (bitsCached >= n)
		{
			ret = (cache>>(bitsCached-n))&maskBits(n);
		}
		else
		{
			//old cache
			var c : Int = cache&maskBits(bitsCached);
			n -= bitsCached;
			//read next & combine
			ret = ((readCache(true)>>WORD_BITS-n)&maskBits(n))|(c<<n);
		}
		return ret;
	}

	public function peekBit() : Int
	{
		var ret : Int;
		if (bitsCached > 0)
		{
			ret = (cache>>(bitsCached-1))&1;
		}
		else
		{
			var word : Int = readCache(true);
			ret = (word>>WORD_BITS-1)&1;
		}
		return ret;
	}

	public function skipBits(n : Int)
	{
		position += n;
		if (n <= bitsCached)
		{
			bitsCached -= n;
		}
		else
		{
			n -= bitsCached;
			while (n >= WORD_BITS)
			{
				n -= WORD_BITS;
				readCache(false);
			}
			if (n > 0)
			{
				cache = readCache(false);
				bitsCached = WORD_BITS-n;
			}
			else
			{
				cache = 0;
				bitsCached = 0;
			}
		}
	}

	public function skipBit()
	{
		position++;
		if (bitsCached > 0)
		{
			bitsCached--;
		}
		else
		{
			cache = readCache(false);
			bitsCached = WORD_BITS-1;
		}
	}

	public function maskBits(n : Int) : Int
	{
		var i : Int;
		if(n==32) i = -1;
		else i = (1<<n)-1;
		return i;
	}
}
