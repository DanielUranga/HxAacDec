package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SyncSampleBox extends FullBox
{

	private var sampleNumbers : Vector<Int>;

	public function new()
	{
		super("Sync Sample Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var entryCount : Int = input.readBytes(4);
		sampleNumbers = new Vector<Int>(entryCount);
		for (i in 0...entryCount)
		{
			sampleNumbers[i] = input.readBytes(4);
		}

		left -= (entryCount+1)*4;
	}

	/**
	 * Gives the numbers of the samples for each entry that are random access
	 * points in the stream.
	 * 
	 * @return a list of sample numbers
	 */
	public function getSampleNumbers() : Vector<Int>
	{
		return sampleNumbers;
	}
	
}