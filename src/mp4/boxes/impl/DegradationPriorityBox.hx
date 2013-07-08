package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.BoxTypes;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DegradationPriorityBox extends FullBox
{

	private var priorities : Vector<Int>;

	public function new()
	{
		super("Degradation Priority Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		//get number of samples from SampleSizeBox
		var sampleCount : Int = (cast(parent.getChild(BoxTypes.SAMPLE_SIZE_BOX), SampleSizeBox)).getSampleCount();

		priorities = new Vector<Int>(sampleCount);
		for (i in 0...sampleCount)
		{
			priorities[i] = input.readBytes(2);
		}
		left -= 2*sampleCount;
	}

	/**
	 * The priority is integer specifying the degradation priority for each
	 * sample.
	 * @return the list of priorities
	 */
	public function getPriorities() : Vector<Int>
	{
		return priorities;
	}
	
}