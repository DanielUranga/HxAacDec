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

class FilterBankTables 
{

	public static inline var ANALYSIS_DELAY : Int = 6;
	//bands and resolutions
	/*
	public static inline var RESOLUTION34 : Array<Int> = [12, 8, 4, 4, 4];
	public static inline var RESOLUTION20 : Array<Int> = [8, 2, 2];
	*/
	public static inline function RESOLUTION34() : Array<Int>
	{
		return [12, 8, 4, 4, 4];
	}
	
	public static inline function RESOLUTION20() : Array<Int>
	{
		return [8, 2, 2];
	}
	
	//filters
	public static var P8_13_20 : Array<Float> = [
		0.00746082949812,
		0.02270420949825,
		0.04546865930473,
		0.07266113929591,
		0.09885108575264,
		0.11793710567217,
		0.125
	];
	public static var P2_13_20 : Array<Float> = [
		0.0,
		0.01899487526049,
		0.0,
		-0.07293139167538,
		0.0,
		0.30596630545168,
		0.5
	];
	public static var P12_13_34 : Array<Float> = [
		0.04081179924692,
		0.03812810994926,
		0.05144908135699,
		0.06399831151592,
		0.07428313801106,
		0.08100347892914,
		0.08333333333333
	];
	public static var P8_13_34 : Array<Float> = [
		0.01565675600122,
		0.03752716391991,
		0.05417891378782,
		0.08417044116767,
		0.10307344158036,
		0.12222452249753,
		0.125
	];
	public static var P4_13_34 : Array<Float> = [
		-0.05908211155639,
		-0.04871498374946,
		0.0,
		0.07778723915851,
		0.16486303567403,
		0.23279856662996,
		0.25
	];
	//DCT tables
	public static var DCT3_4_TABLE : Array<Float> = [
		0.19891236737965806,
		0.38268343236508978,
		0.19891236737965806,
		0.70710678118654757
	];
	public static var DCT3_6_TABLE : Array<Float> = [
		0.70710678118655,
		0.70710678118655,
		0.86602540378444,
		0.5,
		0.96592582628907,
		0.25881904510252
	];
	
}