package mp4.boxes.impl.sampleentries.codec;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class EVCRSpecificStructure extends CodecSpecificStructure
{

	private var framesPerSample : Int;

	public function new()
	{
		super(6);
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		framesPerSample = input.read();
	}

	public function getFramesPerSample() : Int
	{
		return framesPerSample;
	}
	
}