package mp4.boxes.impl.sampleentries.codec;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class H263SpecificStructure extends CodecSpecificStructure
{

	private var level : Int;
	private var profile : Int;

	public function new()
	{
		super(7);
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		level = input.read();
		profile = input.read();
	}

	public function getLevel() : Int
	{
		return level;
	}

	public function getProfile() : Int
	{
		return profile;
	}
	
}