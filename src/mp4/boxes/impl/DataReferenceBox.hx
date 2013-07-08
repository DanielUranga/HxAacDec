package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DataReferenceBox extends FullBox
{

	public function new()
	{
		super("Data Reference Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var entryCount : Int = input.readBytes(4);
		left -= 4;

		readChildren_(input, entryCount); //DataEntryUrlBox, DataEntryUrnBox
	}
	
}