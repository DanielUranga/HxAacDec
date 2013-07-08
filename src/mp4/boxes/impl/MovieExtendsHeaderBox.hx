package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MovieExtendsHeaderBox extends FullBox
{

	private var fragmentDuration : Int;

	public function new()
	{
		super("Movie Extends Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var len : Int = (version==1) ? 8 : 4;
		fragmentDuration = input.readBytes(len);
		left -= len;
	}

	/**
	 * The fragment duration is an integer that declares length of the
	 * presentation of the whole movie including fragments (in the timescale
	 * indicated in the Movie Header Box). The value of this field corresponds
	 * to the duration of the longest track, including movie fragments. If an
	 * MP4 file is created in real-time, such as used in live streaming, it is
	 * not likely that the fragment duration is known in advance and this box
	 * may be omitted.
	 * 
	 * @return the fragment duration
	 */
	public function getFragmentDuration() : Int
	{
		return fragmentDuration;
	}
	
}