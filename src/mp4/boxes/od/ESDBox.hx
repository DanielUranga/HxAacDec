package mp4.boxes.od;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ESDBox extends FullBox
{

	private var esd : ObjectDescriptor;

	public function new()
	{
		super("ESD Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		esd = ObjectDescriptor.createDescriptor(input);
		left -= esd.getBytesRead();
	}

	public function getEntryDescriptor() : ObjectDescriptor
	{
		return esd;
	}
	
}