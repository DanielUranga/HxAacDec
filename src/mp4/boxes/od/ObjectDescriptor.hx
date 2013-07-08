package mp4.boxes.od;
import flash.Vector;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ObjectDescriptor 
{

	public static inline var TYPE_ES_DESCRIPTOR : Int = 3;
	public static inline var TYPE_DECODER_CONFIG_DESCRIPTOR : Int = 4;
	public static inline var TYPE_DECODER_SPECIFIC_INFO_DESCRIPTOR : Int = 5;
	private var type : Int;
	private var size : Int;
	private var bytesRead : Int;
	private var children : Vector<ObjectDescriptor>;

	public static function createDescriptor(input : MP4InputStream) : ObjectDescriptor
	{
		var tag : Int = input.read();
		var read : Int = 1;
		var size : Int = 0;
		var b : Int = 0;
		do {
			b = input.read();
			size <<= 7;
			size |= b&0x7f;
			read++;
		} while((b&0x80)==0x80);
		var desc : ObjectDescriptor;
		switch(tag)
		{
			case TYPE_ES_DESCRIPTOR:
				desc = new ESDescriptor(tag, size);				
			case TYPE_DECODER_CONFIG_DESCRIPTOR:
				desc = new DecoderConfigDescriptor(tag, size);
			case TYPE_DECODER_SPECIFIC_INFO_DESCRIPTOR:
				desc = new DecoderSpecificInfoDescriptor(tag, size);				
			default:
				desc = new UnknownDescriptor(tag, size);
		}

		desc.decode(input);
		input.skipBytes(desc.size-desc.bytesRead);
		desc.bytesRead = read+desc.size;

		return desc;
	}

	public function decode(input : MP4InputStream )
	{
		trace("abstract method called");
	}

	private function new(type : Int, size : Int)
	{
		this.bytesRead = 0;
		this.type = type;
		this.size = size;
		children = new Vector<ObjectDescriptor>();
	}

	//children
	private function readChildren(input : MP4InputStream)
	{
		var desc : ObjectDescriptor;
		while (bytesRead < size)
		{
			desc = createDescriptor(input);
			children.push(desc);
			bytesRead += desc.getBytesRead();
		}
	}

	public function getChildren() : Vector<ObjectDescriptor>
	{
		return children;
	}

	//getter
	public function getType() : Int
	{
		return type;
	}

	public function getBytesRead() : Int
	{
		return bytesRead;
	}
	
}