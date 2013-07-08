package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class PrimaryItemBox extends FullBox
{

	private var itemID : Int;

	public function new()
	{
		super("Primary Item Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		itemID = input.readBytes(2);
		left -= 2;
	}

	/**
	 * The item ID is the identifier of the primary item.
	 *
	 * @return the item ID
	 */
	public function getItemID() : Int
	{
		return itemID;
	}
	
}