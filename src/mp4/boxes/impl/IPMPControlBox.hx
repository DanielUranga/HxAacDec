package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.boxes.od.ObjectDescriptor;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class IPMPControlBox extends FullBox
{

	private var toolList : ObjectDescriptor;
	private var ipmpDescriptors : Vector<ObjectDescriptor>;

	public function new()
	{
		super("IPMP Control Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		toolList = ObjectDescriptor.createDescriptor(input);
		left -= toolList.getBytesRead();

		var count : Int = input.read();
		left--;

		ipmpDescriptors = new Vector<ObjectDescriptor>(count);
		for (i in 0...count)
		{
			ipmpDescriptors[i] = ObjectDescriptor.createDescriptor(input);
			left -= ipmpDescriptors[i].getBytesRead();
		}
	}

	public function getToolList() : ObjectDescriptor
	{
		return toolList;
	}

	public function getIPMPDescriptors() : Vector<ObjectDescriptor>
	{
		return ipmpDescriptors;
	}
	
}