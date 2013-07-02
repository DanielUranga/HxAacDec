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

class Codebooks 
{
	
	public static var TWO_STEP_CODEBOOKS : Array<Array<Array<Array<Int>>>> = [
		[null, null],
		[HCB1.HCB1_1, HCB1.HCB1_2],
		[HCB2.HCB2_1, HCB2.HCB2_2],
		[null, null],
		[HCB4.HCB4_1, HCB4.HCB4_2],
		[null, null],
		[HCB6.HCB6_1, HCB6.HCB6_2],
		[null, null],
		[HCB8.HCB8_1, HCB8.HCB8_2],
		[null, null],
		[HCB10.HCB10_1, HCB10.HCB10_2],
		[HCB11.HCB11_1, HCB11.HCB11_2]
	];
	
	public static var BINARY_CODEBOOKS : Array<Dynamic> = [
		null, null, null, HCB3.HCB3.HCB3, null, HCB5.HCB5.HCB5, null, HCB7.HCB7.HCB7, null, HCB9.HCB9.HCB9, null, null
	];
	
	public static var UNSIGNED_CODEBOOK : Array<Bool> = [false, false, false, true, true, false, false, true, true, true, true, true, false, false, false, false,
		true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true
	];
	
}