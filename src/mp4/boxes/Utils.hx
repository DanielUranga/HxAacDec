/*
 *  Copyright (C) 2011 in-somnia
 * 
 *  This file is part of JAAD.
 * 
 *  JAAD is free software; you can redistribute it and/or modify it 
 *  under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation; either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  JAAD is distributed in the hope that it will be useful, but WITHOUT 
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
package net.sourceforge.jaad.mp4.boxes;

class Utils
{

	private static var UNDETERMINED = 4294967295l;

	public static function getLanguageCode(l : Int) : String
	{
		//1 bit padding, 5*3 bits language code (ISO-639-2/T)
		/*
		char[] c = new char[3];
		c[0] = (char) (((l>>10)&31)+0x60);
		c[1] = (char) (((l>>5)&31)+0x60);
		c[2] = (char) ((l&31)+0x60);
		return new String(c);
		*/
		var c = "";
		c += String.fromCharCode(((l >> 10) & 31) + 0x60);
		c += String.fromCharCode(((l >> 5) & 31) + 0x60);
		c += String.fromCharCode(((l >> 5) & 31) + 0x60);
		return c;
	}

	public static function detectUndetermined(l : Int) : Int
	{
		var x : Int;
		if(l==UNDETERMINED) x = -1;
		else x = l;
		return x;
	}
}
