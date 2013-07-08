package mp4.boxes;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class UnknownBox extends BoxImpl
{

	override public function new()
	{
		super("unknown");
	}

	override public function decode(input : MP4InputStream)
	{
		//no need to read, box will be skipped
	}
	
}