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

import mp4.MP4InputStream;
import mp4.boxes.FullBox;

/**
 * This box contains an explicit timeline map. Each entry defines part of the
 * track time-line: by mapping part of the media time-line, or by indicating
 * 'empty' time, or by defining a 'dwell', where a single time-point in the
 * media is held for a period.
 *
 * Starting offsets for tracks (streams) are represented by an initial empty
 * edit. For example, to play a track from its start for 30 seconds, but at 10
 * seconds into the presentation, we have the following edit list:
 *
 * [0]:
 * Segment-duration = 10 seconds
 * Media-Time = -1
 * Media-Rate = 1
 *
 * [1]:
 * Segment-duration = 30 seconds (could be the length of the whole track)
 * Media-Time = 0 seconds
 * Media-Rate = 1
 */
class EditListBox extends FullBox
{

	var segmentDuration : Array<Int>;
	var mediaTime : Array<Int>;
	var mediaRate : Array<Float>;

	public function new()
	{
		super("Edit List Box");
	}

	override function decode(in_ : MP4InputStream)
	{
		super.decode(in_);

		var entryCount = in_.readBytes(4);
		var len = (version == 1) ? 8 : 4;
		
		/*
		segmentDuration = new long[entryCount];
		mediaTime = new long[entryCount];
		mediaRate = new double[entryCount];
		*/
		segmentDuration = []; segmentDuration.length = entryCount;
		mediaTime = []; mediaTime.length = entryCount;
		mediaRate = []; mediaRate.length = entryCount;
		
		
		for (i in 0...entryCount)
		{
			segmentDuration[i] = in_.readBytes(len);
			mediaTime[i] = in_.readBytes(len);
			
			//int(16) mediaRate_integer;
			//int(16) media_rate_fraction = 0;
			mediaRate[i] = in_.readFixedPoint(16, 16);
		}
	}

	/**
	 * The segment duration is an integer that specifies the duration of this
	 * edit segment in units of the timescale in the Movie Header Box.
	 */
	public function getSegmentDuration()
	{
		return segmentDuration;
	}

	/**
	 * The media time is an integer containing the starting time within the
	 * media of a specific edit segment (in media time scale units, in
	 * composition time). If this field is set to –1, it is an empty edit. The
	 * last edit in a track shall never be an empty edit. Any difference between
	 * the duration in the Movie Header Box, and the track's duration is
	 * expressed as an implicit empty edit at the end.
	 */
	public function getMediaTime()
	{
		return mediaTime;
	}

	/**
	 * The media rate specifies the relative rate at which to play the media
	 * corresponding to a specific edit segment. If this value is 0, then the
	 * edit is specifying a ‘dwell’: the media at media-time is presented for the
	 * segment-duration. Otherwise this field shall contain the value 1.
	 */
	public function getMediaRate()
	{
		return mediaRate;
	}
}
