package mp4.boxes.od;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class UnknownDescriptor extends ObjectDescriptor
{

	public function new(type : Int, size : Int)
	{
		super(type, size);
	}

	override public function decode(input : MP4InputStream)
	{
	}
	
}