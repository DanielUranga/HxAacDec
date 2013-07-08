package mp4.boxes.impl.meta;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class NeroMetadataTagsBox extends BoxImpl
{

	private var pairs : Map<String, String>;

	public function new()
	{
		super("Nero Metadata Tags Box");
		pairs = new Map<String, String>();
	}

	override public function decode(input : MP4InputStream)
	{
		input.skipBytes(12); //meta box
		left -= 12;

		var key : String;
		var val : String;
		var len : Int;
		//TODO: what are the other skipped fields for?
		while (left > 0 && input.read() == 0x80)
		{
			input.skipBytes(2); //x80 x00 x06/x05
			key = input.readUTFString(left, MP4InputStream.UTF8);
			input.skipBytes(4); //0x00 0x01 0x00 0x00 0x00
			len = input.read();
			val = input.readString(len);
			pairs.set(key, val);
			left -= 9+key.length+val.length;
		}
		if(left>0) left--;
	}

	public function getPairs() : Map<String, String>
	{
		return pairs;
	}
	
}