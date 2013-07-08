package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SkipBox extends FullBox
{

	public function new()
	{
		super("Skip Box");
	}

	override public function decode(input : MP4InputStream)
	{
		//no need to read, box will be skipped
	}
	
}