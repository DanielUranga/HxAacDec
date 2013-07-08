package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ProgressiveDownloadInformationBox extends FullBox
{

	private var pairs : Vector<Int>;

	public function new()
	{
		super("Progressive Download Information Box");
		pairs = new Vector<Int>();
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		trace("ProgressiveDownloadInformationBox.decode() fue llamado");
		var rate : Int;
		var initialDelay : Int;
		while (left > 0)
		{
			rate = input.readBytes(4);
			initialDelay = input.readBytes(4);
			//pairs.put(rate, initialDelay);
			pairs[rate] = initialDelay;
			left -= 8;
		}
	}

	/**
	 * The map contains pairs of bitrates and playback delay.
	 * @return the information pairs
	 */
	public function getInformationPairs() : Vector<Int>
	{
		return pairs;
	}
	
}