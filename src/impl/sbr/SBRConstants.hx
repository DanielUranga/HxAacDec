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

package impl.sbr;

class SBRConstants 
{
	public static var MAX_L_E : Int = 5;
	public static var MAX_M : Int = 49;
	public static var FIXFIX : Int = 0;
	public static var FIXVAR : Int = 1;
	public static var VARFIX : Int = 2;
	public static var VARVAR : Int = 3;
	public static var LO_RES : Int = 0;
	public static var HI_RES : Int = 1;
	public static var MAX_NTSRHFG : Int = 40;
	public static var T_HFGEN : Int = 8;
	public static var T_HFADJ : Int = 2;
	public static var RATE : Int = 2;
	public static var TIME_SLOTS : Int = 16;
	public static var TIME_SLOTS_RATE : Int = RATE*TIME_SLOTS;
	//extension IDs
	public static var EXTENSION_ID_PS : Int = 2;
}