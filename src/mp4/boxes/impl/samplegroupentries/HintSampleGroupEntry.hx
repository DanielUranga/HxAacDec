package mp4.boxes.impl.samplegroupentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class HintSampleGroupEntry extends SampleGroupDescriptionEntry
{

	public function new()
	{
		super("Hint Sample Group Entry");
	}

	override public function decode(input : MP4InputStream)
	{
	}
	
}