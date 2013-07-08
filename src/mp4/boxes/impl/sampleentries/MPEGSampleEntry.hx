package mp4.boxes.impl.sampleentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MPEGSampleEntry extends SampleEntry
{

	public function new()
	{
		super("MPEG Sample Entry");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		readChildren(input);
	}
	
}