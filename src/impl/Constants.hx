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

class Constants 
{
	//Logger LOGGER = Logger.getLogger("jaad"); //for debugging
	public static inline var MAX_ELEMENTS  : Int = 16;
	public static inline var BYTE_MASK : Int = 0xFF;
	public static inline var MIN_INPUT_SIZE : Int = 768; //6144 bits/channel
	//frame length
	public static inline var WINDOW_LEN_LONG : Int = 1024;
	public static inline var WINDOW_LEN_SHORT : Int = IntDivision.intDiv(WINDOW_LEN_LONG,8);
	public static inline var WINDOW_SMALL_LEN_LONG : Int = 960;
	public static inline var WINDOW_SMALL_LEN_SHORT : Int = IntDivision.intDiv(WINDOW_SMALL_LEN_LONG,8);
	//element types
	public static inline var ELEMENT_SCE : Int = 0;
	public static inline var ELEMENT_CPE : Int = 1;
	public static inline var ELEMENT_CCE : Int = 2;
	public static inline var ELEMENT_LFE : Int = 3;
	public static inline var ELEMENT_DSE : Int = 4;
	public static inline var ELEMENT_PCE : Int = 5;
	public static inline var ELEMENT_FIL : Int = 6;
	public static inline var ELEMENT_END : Int = 7;
	//maximum number of windows and window groups
	public static inline var MAX_WINDOW_COUNT : Int = 8;
	public static inline var MAX_WINDOW_GROUP_COUNT : Int = MAX_WINDOW_COUNT;
	//maximum number of Scale Window Bands
	public static inline var MAX_SWB_COUNT : Int = 51;
	public static inline var SQRT2 : Float = 1.414213562;
	public static inline var MAX_LTP_SFB : Int = 40;
}