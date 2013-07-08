package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class VideoMediaHeaderBox extends FullBox
{

	private var graphicsMode : Int;
	private var color : Vector<Int>;

	public function new()
	{
		super("Video Media Header Box");
		color = new Vector<Int>(3);
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		graphicsMode = input.readBytes(2);
		//6 byte RGB color
		//color = new Color(in.readBytes(2), in.readBytes(2), in.readBytes(2));
		color[0] = input.readBytes(2);
		color[1] = input.readBytes(2);
		color[2] = input.readBytes(2);
		left -= 8;
	}

	/**
	 * The graphics mode specifies a composition mode for this video track.
	 * Currently, only one mode is defined:
	 * '0': copy over the existing image
	 */
	public function getGraphicsMode() : Int
	{
		return graphicsMode;
	}

	/**
	 * A color available for use by graphics modes.
	 */
	public function getColor() : Vector<Int>
	{
		return color;
	}
	
}