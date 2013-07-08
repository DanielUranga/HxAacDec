package mp4.boxes.impl.sampleentries.codec;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class CodecSpecificStructure 
{
	
	private var size : Int;
	private var vendor : Int;
	private var decoderVersion : Int;

	public function new(size : Int)
	{
		this.size = size;
	}

	public function getSize() : Int
	{
		return size;
	}

	public function decode(input : MP4InputStream)
	{
		vendor = input.readBytes(4);
		decoderVersion = input.read();
	}

	public function getVendor() : Int
	{
		return vendor;
	}

	public function getDecoderVersion() : Int
	{
		return decoderVersion;
	}
	
}