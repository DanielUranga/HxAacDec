/*
 *  Copyright (C) 2011 in-somnia
 * 
 *  This file is part of JAAD.
 * 
 *  JAAD is free software; you can redistribute it and/or modify it 
 *  under the terms of the GNU Lesser General Public License as 
 *  published by the Free Software Foundation; either version 3 of the 
 *  License, or (at your option) any later version.
 *
 *  JAAD is distributed in the hope that it will be useful, but WITHOUT 
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 *  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General 
 *  Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library.
 *  If not, see <http://www.gnu.org/licenses/>.
 */
package mp4.boxes.impl;

import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * This box contains a compact version of a table that allows indexing from
 * decoding time to sample number. Other tables give sample sizes and pointers,
 * from the sample number. Each entry in the table gives the number of
 * consecutive samples with the same time delta, and the delta of those samples.
 * By adding the deltas a complete time-to-sample map may be built.
 * The Decoding Time to Sample Box contains decode time delta's:
 * DT(n+1) = DT(n) + STTS(n)
 * where STTS(n) is the (uncompressed) table entry for sample n.
 * The sample entries are ordered by decoding time stamps; therefore the deltas
 * are all non-negative.
 * The DT axis has a zero origin; DT(i) = SUM(for j=0 to i-1 of delta(j)), and
 * the sum of all deltas gives the length of the media in the track (not mapped
 * to the overall timescale, and not considering any edit list).
 * The Edit List Box provides the initial CT value if it is non-empty
 * (non-zero).
 * 
 * @author in-somnia
 */
class DecodingTimeToSampleBox extends FullBox
{
	
	var sampleCounts : Array<Int>;
	var sampleDeltas : Array<Int>;

	public function new()
	{
		super("Time To Sample Box");
	}
	
	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);
		
		var entryCount = in_.readBytes(4);
		/*
		sampleCounts = new long[entryCount];
		sampleDeltas = new long[entryCount];
		*/
		sampleCounts = [];
		sampleCounts.length = entryCount;
		sampleDeltas = [];
		sampleDeltas.length = entryCount;

		for (i in 0...entryCount)
		{
			sampleCounts[i] = in_.readBytes(4);
			sampleDeltas[i] = in_readBytes(4);
		}
	}

	public function getSampleCounts()
	{
		return sampleCounts;
	}

	public function getSampleDeltas()
	{
		return sampleDeltas;
	}
}
