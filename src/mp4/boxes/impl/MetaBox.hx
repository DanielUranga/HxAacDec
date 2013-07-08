package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class MetaBox extends FullBox
{

	public function new()
	{
		super("Meta Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		readChildren(input);
	}
	
}