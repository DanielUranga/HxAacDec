package mp4.boxes.impl;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class FreeSpaceBox extends BoxImpl
{

	public function new()
	{
		super("Free Space Box");
	}

	override public function decode(input : MP4InputStream)
	{
		//no need to read, box will be skipped
	}
	
}