package mp4.boxes.od;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ESDescriptor extends ObjectDescriptor
{

	public function new(type : Int, size : Int)
	{
		super(type, size);
	}

	override public function decode(input : MP4InputStream)
	{
		input.skipBytes(2);
		var flags : Int = input.read();
		var streamDependenceFlag : Bool = (flags&(1<<7))!=0;
		var urlFlag : Bool = (flags&(1<<6))!=0;
		var ocrFlag : Bool = (flags&(1<<5))!=0;
		bytesRead += 3;
		if (streamDependenceFlag)
		{
			input.skipBytes(2);
			bytesRead += 2;
		}
		if (urlFlag)
		{
			var len : Int = input.read();
			input.skipBytes(len);
			bytesRead += len+1;
		}
		if (ocrFlag)
		{
			input.skipBytes(2);
			bytesRead += 2;
		}

		readChildren(input);
	}
	
}