package mp4.api;
import mp4.boxes.BoxTypes;
import mp4.boxes.impl.sampleentries.codec.CodecSpecificBox;
import mp4.boxes.impl.sampleentries.codec.H263SpecificStructure;

/**
 * ...
 * @author Daniel Uranga
 */

class DecoderInfo 
{

	private var vendor : Int;
	private var decoderVersion : Int;
	private var level : Int;
	private var profile : Int;

	public function new(css : CodecSpecificBox)
	{
		var l : Int = css.getType();
		if (l == BoxTypes.H263_SPECIFIC_BOX)
		{
			var h263 : H263SpecificStructure = cast(css.getCodecSpecificStructure(), H263SpecificStructure);
			vendor = h263.getVendor();
			decoderVersion = h263.getDecoderVersion();
			level = h263.getLevel();
			profile = h263.getProfile();
		}
	}

	public function getDecoderVersion() : Int
	{
		return decoderVersion;
	}

	public function getLevel() : Int
	{
		return level;
	}

	public function getProfile() : Int
	{
		return profile;
	}

	public function getVendor() : Int
	{
		return vendor;
	}
	
}