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

class HCB8 
{
	
	public static var HCB8_1 : Array<Array<Int>> = [
		/* 3 bit codeword */
		[ /* 00000 */0, 0],
		[ /*       */0, 0],
		[ /*       */0, 0],
		[ /*       */0, 0],
		/* 4 bit codewords */
		[ /* 00100 */1, 0],
		[ /*       */1, 0],
		[ /* 00110 */2, 0],
		[ /*       */2, 0],
		[ /* 01000 */3, 0],
		[ /*       */3, 0],
		[ /* 01010 */4, 0],
		[ /*       */4, 0],
		[ /* 01100 */5, 0],
		[ /*       */5, 0],
		/* 5 bit codewords */
		[ /* 01110 */6, 0],
		[ /* 01111 */7, 0],
		[ /* 10000 */8, 0],
		[ /* 10001 */9, 0],
		[ /* 10010 */10, 0],
		[ /* 10011 */11, 0],
		[ /* 10100 */12, 0],
		/* 6 bit codewords */
		[ /* 10101 */13, 1],
		[ /* 10110 */15, 1],
		[ /* 10111 */17, 1],
		[ /* 11000 */19, 1],
		[ /* 11001 */21, 1],
		/* 7 bit codewords */
		[ /* 11010 */23, 2],
		[ /* 11011 */27, 2],
		[ /* 11100 */31, 2],
		/* 7/8 bit codewords */
		[ /* 11101 */35, 3],
		/* 8 bit codewords */
		[ /* 11110 */43, 3],
		/* 8/9/10 bit codewords */
		[ /* 11111 */51, 5]
	];
	
	public static var HCB8_2 : Array<Array<Int>> = [
		/* 3 bit codeword */
		[3, 1, 1],
		/* 4 bit codewords */
		[4, 2, 1],
		[4, 1, 0],
		[4, 1, 2],
		[4, 0, 1],
		[4, 2, 2],
		/* 5 bit codewords */
		[5, 0, 0],
		[5, 2, 0],
		[5, 0, 2],
		[5, 3, 1],
		[5, 1, 3],
		[5, 3, 2],
		[5, 2, 3],
		/* 6 bit codewords */
		[6, 3, 3],
		[6, 4, 1],
		[6, 1, 4],
		[6, 4, 2],
		[6, 2, 4],
		[6, 3, 0],
		[6, 0, 3],
		[6, 4, 3],
		[6, 3, 4],
		[6, 5, 2],
		/* 7 bit codewords */
		[7, 5, 1],
		[7, 2, 5],
		[7, 1, 5],
		[7, 5, 3],
		[7, 3, 5],
		[7, 4, 4],
		[7, 5, 4],
		[7, 0, 4],
		[7, 4, 5],
		[7, 4, 0],
		[7, 2, 6],
		[7, 6, 2],
		/* 7/8 bit codewords */
		[7, 6, 1], [7, 6, 1],
		[7, 1, 6], [7, 1, 6],
		[8, 3, 6],
		[8, 6, 3],
		[8, 5, 5],
		[8, 5, 0],
		/* 8 bit codewords */
		[8, 6, 4],
		[8, 0, 5],
		[8, 4, 6],
		[8, 7, 1],
		[8, 7, 2],
		[8, 2, 7],
		[8, 6, 5],
		[8, 7, 3],
		/* 8/9/10 bit codewords */
		[8, 1, 7], [8, 1, 7], [8, 1, 7], [8, 1, 7],
		[8, 5, 6], [8, 5, 6], [8, 5, 6], [8, 5, 6],
		[8, 3, 7], [8, 3, 7], [8, 3, 7], [8, 3, 7],
		[9, 6, 6], [9, 6, 6],
		[9, 7, 4], [9, 7, 4],
		[9, 6, 0], [9, 6, 0],
		[9, 4, 7], [9, 4, 7],
		[9, 0, 6], [9, 0, 6],
		[9, 7, 5], [9, 7, 5],
		[9, 7, 6], [9, 7, 6],
		[9, 6, 7], [9, 6, 7],
		[10, 5, 7],
		[10, 7, 0],
		[10, 0, 7],
		[10, 7, 7]
	];
}