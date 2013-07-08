package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ItemProtectionBox extends FullBox
{

	public function new()
	{
		super("Item Protection Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var protectionCount : Int = input.readBytes(2);
		left -= 2;
		readChildren_(input, protectionCount);
	}
	
}