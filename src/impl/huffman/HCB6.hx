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

class HCB6 
{
	
	public static var HCB6_1 : Array<Array<Int>> = [
		/* 4 bit codewords */
		[ /* 00000 */0, 0],
		[ /*       */0, 0],
		[ /* 00010 */1, 0],
		[ /*       */1, 0],
		[ /* 00100 */2, 0],
		[ /*       */2, 0],
		[ /* 00110 */3, 0],
		[ /*       */3, 0],
		[ /* 01000 */4, 0],
		[ /*       */4, 0],
		[ /* 01010 */5, 0],
		[ /*       */5, 0],
		[ /* 01100 */6, 0],
		[ /*       */6, 0],
		[ /* 01110 */7, 0],
		[ /*       */7, 0],
		[ /* 10000 */8, 0],
		[ /*       */8, 0],
		/* 6 bit codewords */
		[ /* 10010 */9, 1],
		[ /* 10011 */11, 1],
		[ /* 10100 */13, 1],
		[ /* 10101 */15, 1],
		[ /* 10110 */17, 1],
		[ /* 10111 */19, 1],
		[ /* 11000 */21, 1],
		[ /* 11001 */23, 1],
		/* 7 bit codewords */
		[ /* 11010 */25, 2],
		[ /* 11011 */29, 2],
		[ /* 11100 */33, 2],
		/* 7/8 bit codewords */
		[ /* 11101 */37, 3],
		/* 8/9 bit codewords */
		[ /* 11110 */45, 4],
		/* 9/10/11 bit codewords */
		[ /* 11111 */61, 6]
	];
	
	public static var HCB6_2 : Array<Array<Int>> = [
		/* 4 bit codewords */
		[4, 0, 0],
		[4, 1, 0],
		[4, 0, -1],
		[4, 0, 1],
		[4, -1, 0],
		[4, 1, 1],
		[4, -1, 1],
		[4, 1, -1],
		[4, -1, -1],
		/* 6 bit codewords */
		[6, 2, -1],
		[6, 2, 1],
		[6, -2, 1],
		[6, -2, -1],
		[6, -2, 0],
		[6, -1, 2],
		[6, 2, 0],
		[6, 1, -2],
		[6, 1, 2],
		[6, 0, -2],
		[6, -1, -2],
		[6, 0, 2],
		[6, 2, -2],
		[6, -2, 2],
		[6, -2, -2],
		[6, 2, 2],
		/* 7 bit codewords */
		[7, -3, 1],
		[7, 3, 1],
		[7, 3, -1],
		[7, -1, 3],
		[7, -3, -1],
		[7, 1, 3],
		[7, 1, -3],
		[7, -1, -3],
		[7, 3, 0],
		[7, -3, 0],
		[7, 0, -3],
		[7, 0, 3],
		/* 7/8 bit codewords */
		[7, 3, 2], [7, 3, 2],
		[8, -3, -2],
		[8, -2, 3],
		[8, 2, 3],
		[8, 3, -2],
		[8, 2, -3],
		[8, -2, -3],
		/* 8 bit codewords */
		[8, -3, 2], [8, -3, 2],
		[8, 3, 3], [8, 3, 3],
		[9, 3, -3],
		[9, -3, -3],
		[9, -3, 3],
		[9, 1, -4],
		[9, -1, -4],
		[9, 4, 1],
		[9, -4, 1],
		[9, -4, -1],
		[9, 1, 4],
		[9, 4, -1],
		[9, -1, 4],
		[9, 0, -4],
		/* 9/10/11 bit codewords */
		[9, -4, 2], [9, -4, 2], [9, -4, 2], [9, -4, 2],
		[9, -4, -2], [9, -4, -2], [9, -4, -2], [9, -4, -2],
		[9, 2, 4], [9, 2, 4], [9, 2, 4], [9, 2, 4],
		[9, -2, -4], [9, -2, -4], [9, -2, -4], [9, -2, -4],
		[9, -4, 0], [9, -4, 0], [9, -4, 0], [9, -4, 0],
		[9, 4, 2], [9, 4, 2], [9, 4, 2], [9, 4, 2],
		[9, 4, -2], [9, 4, -2], [9, 4, -2], [9, 4, -2],
		[9, -2, 4], [9, -2, 4], [9, -2, 4], [9, -2, 4],
		[9, 4, 0], [9, 4, 0], [9, 4, 0], [9, 4, 0],
		[9, 2, -4], [9, 2, -4], [9, 2, -4], [9, 2, -4],
		[9, 0, 4], [9, 0, 4], [9, 0, 4], [9, 0, 4],
		[10, -3, -4], [10, -3, -4],
		[10, -3, 4], [10, -3, 4],
		[10, 3, -4], [10, 3, -4],
		[10, 4, -3], [10, 4, -3],
		[10, 3, 4], [10, 3, 4],
		[10, 4, 3], [10, 4, 3],
		[10, -4, 3], [10, -4, 3],
		[10, -4, -3], [10, -4, -3],
		[11, 4, 4],
		[11, -4, 4],
		[11, -4, -4],
		[11, 4, -4]
	];
	
}