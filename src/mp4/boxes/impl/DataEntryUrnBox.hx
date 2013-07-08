package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DataEntryUrnBox extends FullBox
{
	
	private var inFile : Bool;
	private var referenceName : String;
	private var location : String;

	public function new()
	{
		super("Data Entry Urn Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		inFile = (flags&1)==1;
		if (!inFile)
		{
			referenceName = input.readUTFString(left, MP4InputStream.UTF8);
			left -= referenceName.length+1;
			if (left > 0)
			{
				location = input.readUTFString(left, MP4InputStream.UTF8);
				left -= location.length+1;
			}
		}
	}

	public function isInFile() : Bool
	{
		return inFile;
	}

	public function getReferenceName() : String
	{
		return referenceName;
	}

	public function getLocation() : String
	{
		return location;
	}
	
}