package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class CompositionTimeToSampleBox extends FullBox
{

	private var sampleCounts : Vector<Int>;
	private var sampleOffsets : Vector<Int>;

	public function new()
	{
		super("Time To Sample Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		
		var entryCount : Int = input.readBytes(4);
		left -= 4;
		sampleCounts = new Vector<Int>(entryCount);
		sampleOffsets = new Vector<Int>(entryCount);

		for (i in 0...entryCount)
		{
			sampleCounts[i] = input.readBytes(4);
			sampleOffsets[i] = input.readBytes(4);
			left -= 8;
		}
	}

	public function getSampleCounts() : Vector<Int>
	{
		return sampleCounts;
	}

	public function getSampleOffsets() : Vector<Int>
	{
		return sampleOffsets;
	}
	
}