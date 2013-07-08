package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.boxes.od.ObjectDescriptor;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ObjectDescriptorBox extends FullBox
{

	private var objectDescriptor : ObjectDescriptor;

	public function new()
	{
		super("Object Descriptor Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);		
		objectDescriptor = ObjectDescriptor.createDescriptor(input);
		left -= objectDescriptor.getBytesRead();
	}

	public function getObjectDescriptor() : ObjectDescriptor
	{
		return objectDescriptor;
	}
	
}