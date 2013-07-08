package mp4.boxes.impl.samplegroupentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class AudioSampleGroupEntry extends SampleGroupDescriptionEntry
{

	public function new()
	{
		super("Audio Sample Group Entry");
	}

	override public function decode(input : MP4InputStream)
	{
	}
	
}