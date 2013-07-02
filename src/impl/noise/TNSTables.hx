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
	
package impl.noise;
import flash.Vector;

class TNSTables 
{
	
	public static var TNS_COEF_0_3 : Array<Float> =
	[
		0.0, 0.4338837391, 0.7818314825, 0.9749279122,
		-0.9848077530, -0.8660254038, -0.6427876097, -0.3420201433,
		-0.4338837391, -0.7818314825, -0.9749279122, -0.9749279122,
		-0.9848077530, -0.8660254038, -0.6427876097, -0.3420201433
	];
	
	public static var TNS_COEF_0_4 : Array<Float> =
	[
		0.0, 0.2079116908, 0.4067366431, 0.5877852523,
		0.7431448255, 0.8660254038, 0.9510565163, 0.9945218954,
		-0.9957341763, -0.9618256432, -0.8951632914, -0.7980172273,
		-0.6736956436, -0.5264321629, -0.3612416662, -0.1837495178
	];
	
	public static var TNS_COEF_1_3 : Array<Float> =
	[
		0.0, 0.4338837391, -0.6427876097, -0.3420201433,
		0.9749279122, 0.7818314825, -0.6427876097, -0.3420201433,
		-0.4338837391, -0.7818314825, -0.6427876097, -0.3420201433,
		-0.7818314825, -0.4338837391, -0.6427876097, -0.3420201433
	];
	
	public static var TNS_COEF_1_4 : Array<Float> =
	[
		0, 0.2079116908, 0.4067366431, 0.5877852523,
		-0.6736956436, -0.5264321629, -0.3612416662, -0.1837495178,
		0.9945218954, 0.9510565163, 0.8660254038, 0.7431448255,
		-0.6736956436, -0.5264321629, -0.3612416662, -0.1837495178
	];
	
	public static var TNS_TABLES : Array<Array<Float>> =
	[
		TNS_COEF_0_3, TNS_COEF_0_4, TNS_COEF_1_3, TNS_COEF_1_4
	];
	
}