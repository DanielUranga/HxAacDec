package mp4.boxes.od;
import haxe.io.BytesData;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class DecoderSpecificInfoDescriptor extends ObjectDescriptor
{

	private var data : BytesData;

	public function new(type : Int, size : Int)
	{
		super(type, size);
	}

	override public function decode(input : MP4InputStream)
	{
		//data = new byte[size];
		data = new BytesData();
		data.length = size;
		input.readBytes_(data);
		bytesRead += size;
	}

	public function getData() : BytesData
	{
		return data;
	}
	
}