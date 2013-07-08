package mp4.boxes.impl.sampleentries.codec;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class UnknownCodecSpecificStructure extends CodecSpecificStructure
{

	public function new()
	{
		super(0);
	}

	override public function decode(input : MP4InputStream)
	{
	}
	
}