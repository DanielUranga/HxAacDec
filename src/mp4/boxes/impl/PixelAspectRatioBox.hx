package mp4.boxes.impl;
import mp4.boxes.BoxImpl;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class PixelAspectRatioBox extends BoxImpl
{

	private var hSpacing : Int;
	private var vSpacing : Int;

	public function new()
	{
		super("Pixel Aspect Ratio Box");
	}

	override public function decode(input : MP4InputStream)
	{
		hSpacing = input.readBytes(4);
		vSpacing = input.readBytes(4);
		left -= 8;
	}

	public function getHorizontalSpacing() : Int
	{
		return hSpacing;
	}

	public function getVerticalSpacing() : Int
	{
		return vSpacing;
	}
	
}