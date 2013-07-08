package mp4.boxes.od;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DecoderConfigDescriptor extends ObjectDescriptor
{

	public function new(type : Int, size : Int)
	{
		super(type, size);
	}

	override public function decode(input : MP4InputStream)
	{
		input.skipBytes(13);
		bytesRead += 13;
		
		readChildren(input);
	}
	
}