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
import haxe.io.BytesData;

class DSE extends Element
{

	//private byte[] dataStreamBytes;
	private var dataStreamBytes : BytesData;

	public function new()
	{
		//super();
	}

	public function decode(input : BitStream)
	{
		var byteAlign : Bool = input.readBool();
		var count : Int = input.readBits(8);
		if(count==255) count += input.readBits(8);

		if(byteAlign) input.byteAlign();

		dataStreamBytes = new BytesData();
		for (i in 0...count)
		{
			//dataStreamBytes[i] = (byte) in.readBits(8);
			dataStreamBytes[i] = input.readBits(8);
		}
	}
	
}