package mp4.boxes.impl;
import haxe.io.BytesData;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class BinaryXMLBox extends FullBox
{

	private var data : BytesData;

	public function new()
	{
		super("Binary XML Box");
	}
	
	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		data = new BytesData();
		data.length = left;
		input.readBytes_(data);
		left = 0;
	}

	/**
	 * The binary data.
	 */
	public function getData() : BytesData
	{
		return data;
	}
	
}