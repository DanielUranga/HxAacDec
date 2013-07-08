package mp4.boxes;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class FullBox extends BoxImpl
{

	private var version : Int;
	private var flags : Int;
	
	override public function new(name : String) 
	{
		super(name);
	}
	
	override public function decode(input : MP4InputStream)
	{
		version = input.read();
		flags = input.readBytes(3);
		left -= 4;
	}
	
}