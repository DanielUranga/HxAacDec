package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MediaDataBox extends FullBox
{
	public function new()
	{
		super("Media Data Box");
	}

	override public function decode(input : MP4InputStream)
	{
		//if random access: skip, else: do nothing
	}
	
}