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
import flash.utils.ByteArray;
import flash.Vector;
import haxe.io.Bytes;
import haxe.io.BytesData;

class BitStream 
{
	var maskBits : Array<Int>;
	
	private static inline var WORD_BITS : Int = 32;
	private static inline var WORD_BYTES : Int = 4;
	private static inline var BYTE_MASK : Int = 0xff;
	//private var buffer : BytesData;	
	var buffer : Vector<Int>;
	var pos : Int; //offset in the buffer array
	var cache : Int; //current 4 bytes, that are read from the buffer
	var bitsCached : Int; //remaining bits in current cache
	var position : Int; //number of total bits read

	public function new( ?data : BytesData )
	{
		maskBits = [
		0, 1, 3, 7, 15, 31, 63, 127, 255, 511, 1023, 2047, 4095, 8191, 16383, 32767, 65535, 131071,
		262143, 524287, 1048575, 2097151, 4194303, 8388607, 16777215, 33554431, 67108863, 134217727,
		268435455, 536870911, 1073741823, 2147483647, -1];
		reset();
		//buffer = new BytesData();
		buffer = new Vector<Int>();
		if ( data != null )
		{
			setData(data);
		}
	}

	public function destroy()
	{
		reset();
	}

	public function setData(data : BytesData)
	{
		/*
		buffer = new BytesData();
		buffer.writeBytes(data, 0, data.length);
		buffer.length = Math.floor(WORD_BYTES * ((data.length + WORD_BYTES - 1) / WORD_BYTES));
		*/
		buffer.length = Math.floor(WORD_BYTES * ((data.length + WORD_BYTES - 1) / WORD_BYTES));
		for ( i in 0...data.length )
		{
			buffer[i] = data[i];
		}
		reset();		
	}
	
	public function addData(data : BytesData)
	{
		//buffer.writeBytes(data);
		while (data.bytesAvailable > 0)
		{
			buffer.push(data.readByte());
		}
		/*
		var start : Int = buffer.length;
		buffer.length += data.length;
		for ( i in start...buffer.length )
		{
			trace(i + " " + (i - data.length));
			buffer[i] = data[i - data.length];
		}
		*/
	}

	public inline function byteAlign()
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

	/**
	 * Devuelve la posicion en bits
	 */
	public inline function getPosition()
	{
		return position;
	}
	
	/**
	 * 
	 * @param	position La posicion en bits
	 */
	public function setPosition(position : Int)
	{
		trace("seek2 " + position/8);		
		this.pos = Std.int(position/8);
		bitsCached = 0;
	}

	public inline function getBitsLeft()
	{
		return 8*(buffer.length-pos)+bitsCached;
	}

	/**
	 * Reads the next four bytes.
	 * @param peek if true, the stream pointer will not be increased
	 */
	public /*inline*/ function readCache(peek : Bool) : Int
	{
		if(pos>buffer.length-WORD_BYTES)
		{
			return throw ("end of stream");
		}
		var i : Int
		//if(pos>buffer.length-WORD_BYTES) throw ("end of stream");
		= ((buffer[pos]&BYTE_MASK)<<24)
					|((buffer[pos+1]&BYTE_MASK)<<16)
					|((buffer[pos+2]&BYTE_MASK)<<8)
					|(buffer[pos+3]&BYTE_MASK);
		if(!peek) pos += WORD_BYTES;
		return i;
	}

	public function readBits(n : Int) : Int
	{
		//if(getBitsLeft()<n) throw("invalid data: less than "+n+" bits left, buffer.length="+buffer.length+", pos="+pos+", bitsLeft="+bitsCached);
		var result : Int;
		position += n;
		if (bitsCached >= n)
		{
			bitsCached -= n;
			result = (cache>>bitsCached)&maskBits[n];
			//position += n;
		}
		else
		{
			//position += n;
			var c : Int = cache&maskBits[bitsCached];
			var left : Int = n-bitsCached;
			cache = readCache(false);
			bitsCached = WORD_BITS-left;
			result = ((cache>>bitsCached)&maskBits[left])|(c<<left);
		}
		return result;
	}
	
	// Returns a byte
	public inline function read() : Int
	{
		return readBits(8);
	}
	
	// Skip n bytes
	public function skip( n : Int ) : Int
	{
		for ( i in 0...n )
		{
			//try
			//{
				skipBits(8);
			//}
			//catch (e : Dynamic)
			//{
			//	return i;
			//}
		}
		return n;
	}
	
	public function readBit() : Int
	{
		//if(getBitsLeft()<1) throw("invalid data: less than 1 bit left, position: "+position);
		var i : Int;
		position++;
		if (bitsCached > 0)
		{
			bitsCached--;
			i = (cache>>(bitsCached))&1;
			//position++;
		}
		else
		{
			cache = readCache(false);
			bitsCached = WORD_BITS-1;
			//position++;
			i = (cache>>bitsCached)&1;
		}
		return i;
	}

	public inline function readBool() : Bool
	{
		return (readBit()&0x1)!=0;
	}

	public function peekBits(n : Int) : Int
	{
		var ret : Int;
		if (bitsCached >= n)
		{
			ret = (cache>>(bitsCached-n))&maskBits[n];
		}
		else
		{
			//old cache
			var c : Int = cache&maskBits[bitsCached];
			n -= bitsCached;
			//read next & combine
			ret = ((readCache(true)>>WORD_BITS-n)&maskBits[n])|(c<<n);
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
}
