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

class IntMath 
{
	
	public static inline function min(a : Int, b : Int) : Int
	{
		if ( a < b )
			return a;
		else
			return b;
	}
	
	public static inline function max(a : Int, b : Int) : Int
	{
		if ( a > b )
			return a;
		else
			return b;
	}
	
	public static inline function abs(a : Int) : Int
	{
		if (a >= 0)
			return a;
		else
			return -a;
	}
	
	public static inline function compare( x:Int, y:Int ) : Int
	{
		if (x < y)
			return -1;
		else if (x > y)
			return 1;
		else
			return 0;
	}
	
}