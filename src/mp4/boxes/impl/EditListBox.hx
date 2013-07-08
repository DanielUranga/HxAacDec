package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class EditListBox extends FullBox
{

	private var segmentDuration : Vector<Int>;
	private var mediaTime : Vector<Int>;
	private var mediaRate : Vector<Float>;

	public function new()
	{
		super("Edit List Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var entryCount : Int = input.readBytes(4);
		left -= 4;
		var len : Int = (version==1) ? 8 : 4;

		segmentDuration = new Vector<Int>(entryCount);
		mediaTime = new Vector<Int>(entryCount);
		mediaRate = new Vector<Float>(entryCount);

		for (i in 0...entryCount)
		{
			segmentDuration[i] = input.readBytes(len);
			mediaTime[i] = input.readBytes(len);

			//int(16) mediaRate_integer;
			//int(16) media_rate_fraction = 0;
			mediaRate[i] = input.readFixedPoint(4, MP4InputStream.MASK16);
			left -= (2*len)+4;
		}
	}

	/**
	 * The segment duration is an integer that specifies the duration of this
	 * edit segment in units of the timescale in the Movie Header Box.
	 */
	public function getSegmentDuration() : Vector<Int>
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
	public function getMediaTime() : Vector<Int>
	{
		return mediaTime;
	}

	/**
	 * The media rate specifies the relative rate at which to play the media
	 * corresponding to a specific edit segment. If this value is 0, then the
	 * edit is specifying a ‘dwell’: the media at media-time is presented for the
	 * segment-duration. Otherwise this field shall contain the value 1.
	 */
	public function getMediaRate() : Vector<Float>
	{
		return mediaRate;
	}
	
}