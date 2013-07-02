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
	
package impl.error;

import flash.Vector;
import impl.BitStream;
import impl.huffman.HCB;
import impl.huffman.Huffman;
import impl.ICSInfo;
import impl.ICStream;
import impl.IntDivision;
import impl.IntMath;
import impl.SectionData;

class Codeword
{
	public var cb : Int;
	public var decoded : Int;
	public var sp_offset : Int;
	public var bits : BitsBuffer;
	public function fill(sp : Int, cb : Int)
	{
		sp_offset = sp;
		this.cb = cb;
		decoded = 0;
		bits = new BitsBuffer();
	}
}
 
class HCR 
{
	private static inline var NUM_CB : Int = 6;
	private static inline var NUM_CB_ER : Int = 22;
	private static inline var MAX_CB : Int = 32;
	private static inline var VCB11_FIRST : Int = 16;
	private static inline var VCB11_LAST : Int = 31;
	private static var PRE_SORT_CB_STD : Array<Int> = [11, 9, 7, 5, 3, 1];
	private static var PRE_SORT_CB_ER : Array<Int> = [11, 31, 30, 29, 28, 27, 26, 25, 24, 23, 22, 21, 20, 19, 18, 17, 16, 9, 7, 5, 3, 1];
	private static var MAX_CW_LEN : Array<Int> = [0, 11, 9, 20, 16, 13, 11, 14, 12, 17, 14, 49,
		0, 0, 0, 0, 14, 17, 21, 21, 25, 25, 29, 29, 29, 29, 33, 33, 33, 37, 37, 41];
	//bit-twiddling helpers
	private static var S : Array<Int> = [1, 2, 4, 8, 16];
	private static var B : Array<Int> = [0x55555555, 0x33333333, 0x0F0F0F0F, 0x00FF00FF, 0x0000FFFF];
		//32 bit rewind and reverse
	
	private static function rewindReverse(v : Int, len : Int) : Int
	{
		v = ((v>>S[0])&B[0])|((v<<S[0])&~B[0]);
		v = ((v>>S[1])&B[1])|((v<<S[1])&~B[1]);
		v = ((v>>S[2])&B[2])|((v<<S[2])&~B[2]);
		v = ((v>>S[3])&B[3])|((v<<S[3])&~B[3]);
		v = ((v>>S[4])&B[4])|((v<<S[4])&~B[4]);
		//shift off low bits
		v >>= (32-len);
		return v;
	}
	
	public static function rewindReverse64(hi : Int, lo : Int, len : Int) : Array<Int>
	{
		var i : Array<Int> = [0,0];
		if (len <= 32)
		{
			i[0] = 0;
			i[1] = rewindReverse(lo, len);
		}
		else
		{
			lo = ((lo>>S[0])&B[0])|((lo<<S[0])&~B[0]);
			hi = ((hi>>S[0])&B[0])|((hi<<S[0])&~B[0]);
			lo = ((lo>>S[1])&B[1])|((lo<<S[1])&~B[1]);
			hi = ((hi>>S[1])&B[1])|((hi<<S[1])&~B[1]);
			lo = ((lo>>S[2])&B[2])|((lo<<S[2])&~B[2]);
			hi = ((hi>>S[2])&B[2])|((hi<<S[2])&~B[2]);
			lo = ((lo>>S[3])&B[3])|((lo<<S[3])&~B[3]);
			hi = ((hi>>S[3])&B[3])|((hi<<S[3])&~B[3]);
			lo = ((lo>>S[4])&B[4])|((lo<<S[4])&~B[4]);
			hi = ((hi>>S[4])&B[4])|((hi<<S[4])&~B[4]);
			//shift off low bits
			i[1] = (hi>>(64-len))|(lo<<(len-32));
			i[1] = lo>>(64-len);
		}
		return i;
	}
	
	private static function isGoodCB(cb : Int, sectCB : Int) : Bool
	{
		var b : Bool = false;
		if ((sectCB > HCB.ZERO_HCB && sectCB <= HCB.ESCAPE_HCB) || (sectCB >= VCB11_FIRST && sectCB <= VCB11_LAST))
		{
			if(cb<HCB.ESCAPE_HCB) b = ((sectCB==cb)||(sectCB==cb+1));
			else b = (sectCB==cb);
		}
		return b;
	}
	
	public static function decodeReorderedSpectralData(huffman : Huffman, ics : ICStream, input : BitStream, spectralData : Vector<Int>, sectionDataResilience : Bool)
	{
		var info : ICSInfo = ics.getInfo();
		var windowGroupCount : Int = info.getWindowGroupCount();
		var maxSFB : Int = info.getMaxSFB();
		var swbOffsets : Vector<Int> = info.getSWBOffsets();
		var swbOffsetMax : Int = info.getSWBOffsetMax();
		var sectData : SectionData = ics.getSectionData();
		var sectStart : Vector<Vector<Int>> = sectData.getSectStart();
		var sectEnd : Vector<Vector<Int>> = sectData.getSectEnd();
		var numSec : Vector<Int> = sectData.getNumSec();
		var sectCB : Vector<Vector<Int>> = sectData.getSectCB();
		var sectSFBOffsets : Vector<Vector<Int>> = info.getSectSFBOffsets();

		//check parameter
		var spDataLen : Int = ics.getReorderedSpectralDataLength();
		if(spDataLen==0) return;

		var longestLen : Int = ics.getLongestCodewordLength();
		if(longestLen==0||longestLen>=spDataLen) throw("length of longest HCR codeword out of range");

		//create spOffsets
		var spOffsets : Vector<Int> = new Vector<Int>(8);
		var shortFrameLen : Int = IntDivision.intDiv(spectralData.length, 8);
		spOffsets[0] = 0;
		for (g in 1...windowGroupCount)
		{
			spOffsets[g] = spOffsets[g-1]+shortFrameLen*info.getWindowGroupLength(g-1);
		}

		var codeword : Vector<Codeword> = new Vector<Codeword>(512);
		var segment : Vector<BitsBuffer> = new Vector<BitsBuffer>(512);

		var lastCB : Int;
		var preSortCB : Array<Int>;
		if (sectionDataResilience)
		{
			preSortCB = PRE_SORT_CB_ER;
			lastCB = NUM_CB_ER;
		}
		else
		{
			preSortCB = PRE_SORT_CB_STD;
			lastCB = NUM_CB;
		}

		var PCWs_done : Int = 0;
		var segmentsCount : Int = 0;
		var numberOfCodewords : Int = 0;
		var bitsread : Int = 0;

		var sfb : Int;
		var w_idx : Int;
		var thisCB : Int;
		var thisSectCB : Int;
		var cws : Int;
		//step 1: decode PCW's (set 0), and stuff data in easier-to-use format
		for (sortloop in 0...lastCB)
		{
			//select codebook to process this pass
			thisCB = preSortCB[sortloop];

			for (sfb in 0...maxSFB)
			{
				w_idx = 0;
				while (4 * w_idx < (IntMath.min(swbOffsets[sfb + 1], swbOffsetMax) - swbOffsets[sfb]))
				{
					for (g in 0...windowGroupCount)
					{
						for (i in 0...numSec[g])
						{
							if ((sectStart[g][i]<=sfb)&&(sectEnd[g][i]>sfb))
							{
								//check whether codebook used here is the one we want to process
								thisSectCB = sectCB[g][i];

								if (isGoodCB(thisCB, thisSectCB))
								{
									//precalculation
									var sect_sfb_size : Int = sectSFBOffsets[g][sfb+1]-sectSFBOffsets[g][sfb];
									var inc : Int = (thisSectCB<HCB.FIRST_PAIR_HCB) ? 4 : 2;
									var group_cws_count : Int = IntDivision.intDiv(4*info.getWindowGroupLength(g), inc);
									var segwidth : Int = IntMath.min(MAX_CW_LEN[thisSectCB], longestLen);

									//read codewords until end of sfb or end of window group
									cws = 0;
									while ((cws < group_cws_count) && ((cws + w_idx * group_cws_count) < sect_sfb_size))
									{
										var sp : Int = spOffsets[g]+sectSFBOffsets[g][sfb]+inc*(cws+w_idx*group_cws_count);

										//read and decode PCW
										if (PCWs_done == 0)
										{
											//read in normal segments
											if (bitsread + segwidth <= spDataLen)
											{
												segment[segmentsCount].readSegment(segwidth, input);
												bitsread += segwidth;

												huffman.decodeSpectralDataER(segment[segmentsCount], thisSectCB, spectralData, sp);

												//keep leftover bits
												segment[segmentsCount].rewindReverse();

												segmentsCount++;
											}
											else
											{
												//remaining after last segment
												if (bitsread < spDataLen)
												{
													var additional_bits : Int = spDataLen-bitsread;

													segment[segmentsCount].readSegment(additional_bits, input);
													segment[segmentsCount].len += segment[segmentsCount-1].len;
													segment[segmentsCount].rewindReverse();

													if (segment[segmentsCount - 1].len > 32)
													{
														segment[segmentsCount-1].bufb = segment[segmentsCount].bufb
																+segment[segmentsCount-1].showBits(segment[segmentsCount-1].len-32);
														segment[segmentsCount-1].bufa = segment[segmentsCount].bufa
																+segment[segmentsCount-1].showBits(32);
													}
													else
													{
														segment[segmentsCount-1].bufa = segment[segmentsCount].bufa
																+segment[segmentsCount-1].showBits(segment[segmentsCount-1].len);
														segment[segmentsCount-1].bufb = segment[segmentsCount].bufb;
													}
													segment[segmentsCount-1].len += additional_bits;
												}
												bitsread = spDataLen;
												PCWs_done = 1;

												codeword[0].fill(sp, thisSectCB);
											}
										}
										else
										{
											codeword[numberOfCodewords-segmentsCount].fill(sp, thisSectCB);
										}
										numberOfCodewords++;
										cws++;
									}
								}
							}
						}
					}
					w_idx++;
				}
			}
		}

		if(segmentsCount==0) throw("no segments in HCR");

		var numberOfSets : Int = IntDivision.intDiv(numberOfCodewords, segmentsCount);

		//step 2: decode nonPCWs
		var trial : Int;
		var codewordBase : Int;
		var segmentID : Int;
		var codewordID : Int;
		for (set in 1...(numberOfSets+1))
		{
			for (trial in 0...segmentsCount)
			{
				for (codewordBase in 0...segmentsCount)
				{
					segmentID = (trial+codewordBase)%segmentsCount;
					codewordID = codewordBase+set*segmentsCount-segmentsCount;

					//data up
					if(codewordID>=numberOfCodewords-segmentsCount) break;

					if ((codeword[codewordID].decoded == 0) && (segment[segmentID].len > 0))
					{
						if(codeword[codewordID].bits.len!=0) segment[segmentID].concatBits(codeword[codewordID].bits);

						var tmplen : Int = segment[segmentID].len;
						var ret : Int = huffman.decodeSpectralDataER(segment[segmentID], codeword[codewordID].cb,
								spectralData, codeword[codewordID].sp_offset);

						if(ret>=0) codeword[codewordID].decoded = 1;
						else
						{
							codeword[codewordID].bits = segment[segmentID];
							codeword[codewordID].bits.len = tmplen;
						}

					}
				}
			}
			for (i in 0...segmentsCount)
			{
				segment[i].rewindReverse();
			}
		}
	}
	
}