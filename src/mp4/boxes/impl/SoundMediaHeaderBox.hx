package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SoundMediaHeaderBox extends FullBox
{

	private var balance : Float;

	public function new()
	{
		super("Sound Media Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		balance = input.readFixedPoint(2, MP4InputStream.MASK8);
		input.skipBytes(2); //reserved
		left -= 4;
	}

	/**
	 * The balance is a floating-point number that places mono audio tracks in a
	 * stereo space: 0 is centre (the normal value), full left is -1.0 and full
	 * right is 1.0.
	 *
	 * @return the stereo balance for a mono track
	 */
	public function getBalance() : Float
	{
		return balance;
	}
	
}