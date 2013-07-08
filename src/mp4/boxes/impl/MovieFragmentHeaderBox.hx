package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MovieFragmentHeaderBox extends FullBox
{

	private var sequenceNumber : Int;

	public function new()
	{
		super("Movie Fragment Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		sequenceNumber = input.readBytes(4);
		left -= 4;
	}

	/**
	 * The ordinal number of this fragment, in increasing order.
	 */
	public function getSequenceNumber() : Int
	{
		return sequenceNumber;
	}
	
}