package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DataEntryUrlBox extends FullBox
{
	
	private var inFile : Bool;
	private var location : String;

	public function new()
	{
		super("Data Entry Url Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		inFile = (flags&1)==1;
		if (!inFile)
		{
			location = input.readUTFString(left, MP4InputStream.UTF8);
			left -= location.length+1;
		}
	}

	public function isInFile() : Bool
	{
		return inFile;
	}

	public function getLocation() : String
	{
		return location;
	}
	
}