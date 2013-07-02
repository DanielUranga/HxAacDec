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

class HCB 
{
	public static inline var ZERO_HCB : Int = 0;
	public static inline var ESCAPE_HCB : Int = 11;
	public static inline var NOISE_HCB : Int = 13;
	public static inline var INTENSITY_HCB2 : Int = 14;
	public static inline var INTENSITY_HCB : Int = 15;
	public static inline var FIRST_PAIR_HCB : Int = 5;
}