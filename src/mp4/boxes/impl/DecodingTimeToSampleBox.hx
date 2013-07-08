package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DecodingTimeToSampleBox extends FullBox
{

	private var sampleCounts : Vector<Int>;
	private var sampleDeltas : Vector<Int>;

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
		sampleDeltas = new Vector<Int>(entryCount);

		for (i in 0...entryCount)
		{
			sampleCounts[i] = input.readBytes(4);
			sampleDeltas[i] = input.readBytes(4);
			left -= 8;
		}
	}

	public function getSampleCounts() : Vector<Int>
	{
		return sampleCounts;
	}

	public function getSampleDeltas() : Vector<Int>
	{
		return sampleDeltas;
	}
	
}