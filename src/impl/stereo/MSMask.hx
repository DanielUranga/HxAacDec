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

package impl.stereo;

class MSMask 
{

	public static var TYPE_ALL_0 : MSMask = new MSMask(0);
	public static var TYPE_USED : MSMask = new MSMask(1);
	public static var TYPE_ALL_1 : MSMask = new MSMask(2);
	public static var TYPE_RESERVED : MSMask = new MSMask(3);

	public static inline function forInt(i : Int) : MSMask
	{
		var m : MSMask = TYPE_ALL_0;
		switch(i)
		{
			case 0:
				m = TYPE_ALL_0;
			case 1:
				m = TYPE_USED;
			case 2:
				m = TYPE_ALL_1;
			case 3:
				m = TYPE_RESERVED;
			default:
				throw("unknown MS mask type");
		}
		return m;
	}
	private var num : Int;

	private function new(num : Int)
	{
		this.num = num;
	}
	
}