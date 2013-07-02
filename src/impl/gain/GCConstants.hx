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

package impl.gain;

class GCConstants 
{

	public static var BANDS : Int = 4;
	public static var MAX_CHANNELS : Int = 5;
	public static var NPQFTAPS : Int = 96;
	public static var NPEPARTS : Int = 64;	//number of pre-echo inhibition parts
	public static var ID_GAIN : Int = 16;
	public static var LN_GAIN : Array<Int> = [
		-4, -3, -2, -1, 0, 1, 2, 3,
		4, 5, 6, 7, 8, 9, 10, 11
	];
	
}