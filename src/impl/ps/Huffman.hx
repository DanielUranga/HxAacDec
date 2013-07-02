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

package impl.ps;
import flash.Vector;
import impl.BitStream;

class Huffman 
{
	
	public static function decode(input : BitStream,
								time : Bool,
								pars : Int,
								huffT : Array<Array<Int>>,
								huffF : Array<Array<Int>>,
								par : Vector<Int>)
	{		
		if (time)
		{
			for (n in 0...pars)
			{
				par[n] = decodeHuffman(input, huffT);
			}
		}
		else
		{
			par[0] = decodeHuffman(input, huffF);
			for (n in 1...pars)
			{
				par[n] = decodeHuffman(input, huffF);
			}
		}
	}

	private static function decodeHuffman(input : BitStream, table : Array<Array<Int>>) : Int
	{
		var bit : Int;
		var index : Int = 0;

		while (index >= 0)
		{
			bit = input.readBit();
			index = table[index][bit];
		}

		return index+31;
	}
	
}