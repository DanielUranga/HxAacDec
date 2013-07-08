package mp4.boxes.impl.sampleentries;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class AudioSampleEntry extends SampleEntry
{

	private var channelCount : Int;
	private var sampleSize : Int;
	private var sampleRate : Int;

	public function new()
	{
		super("Audio Sample Entry");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		input.skipBytes(8); //reserved
		channelCount = input.readBytes(2);
		sampleSize = input.readBytes(2);
		input.skipBytes(2); //pre-defined: 0
		input.skipBytes(2); //reserved
		sampleRate = ((input.readBytes(4)>>16)&0xFFFF);
		left -= 20;

		readChildren(input);
	}

	public function getChannelCount() : Int
	{
		return channelCount;
	}

	public function getSampleRate() : Int
	{
		return sampleRate;
	}

	public function getSampleSize() : Int
	{
		return sampleSize;
	}
	
}