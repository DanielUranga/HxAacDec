package mp4.boxes.impl.sampleentries.codec;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class AMRSpecificStructure extends CodecSpecificStructure
{

	private var modeSet : Int;
	private var modeChangePeriod : Int;
	private var framesPerSample : Int;

	public function new()
	{
		super(9);
	}

	override function decode(input : MP4InputStream)
	{
		super.decode(input);
		modeSet = input.readBytes(2);
		modeChangePeriod = input.read();
		framesPerSample = input.read();
	}

	public function getModeSet() : Int
	{
		return modeSet;
	}

	public function getModeChangePeriod() : Int
	{
		return modeChangePeriod;
	}

	public function getFramesPerSample() : Int
	{
		return framesPerSample;
	}
	
}