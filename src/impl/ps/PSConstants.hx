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

class PSConstants 
{

	public static inline var MAX_PS_ENVELOPES : Int = 5;
	public static inline var NO_ALLPASS_LINKS : Int = 3;
	public static inline var SHORT_DELAY_BAND : Int = 35;
	public static inline var NR_ALLPASS_BANDS : Int = 22;
	public static inline var ALPHA_DECAY : Float = 0.76592833836465;
	public static inline var ALPHA_SMOOTH : Float = 0.25;
	public static inline var DECAY_SLOPE : Float = 0.05;
	public static inline var SQRT2 : Float = 1.414213562;
	public static inline var RATE : Int = 2;
	public static inline var TIME_SLOTS : Int = 16;
	public static inline var TIME_SLOTS_RATE : Int = RATE*TIME_SLOTS;
	public static inline var EXTENSION_ID_IPDOPD : Int = 0;
	public static inline var REDUCTION_RATIO_GAMMA : Float = 1.5;
	public static inline var IID_STEPS_LONG : Int = 15;
	public static inline var IID_STEPS_SHORT : Int = 7;
	
}