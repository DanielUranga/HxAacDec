package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class XMLBox extends FullBox
{

	private var content : String;

	public function new()
	{
		super("XML Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		
		content = input.readUTFString1(left);
		left -= content.length;
	}

	/**
	 * The XML content.
	 */
	public function getContent() : String
	{
		return content;
	}
	
}