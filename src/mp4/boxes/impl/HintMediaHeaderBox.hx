package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class HintMediaHeaderBox extends FullBox
{

	private var maxPDUsize : Int;
	private var avgPDUsize : Int;
	private var maxBitrate : Int;
	private var avgBitrate : Int;

	public function new()
	{
		super("Hint Media Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		maxPDUsize = input.readBytes(2);
		avgPDUsize = input.readBytes(2);

		maxBitrate = input.readBytes(4);
		avgBitrate = input.readBytes(4);

		input.skipBytes(4); //reserved

		left -= 16;
	}

	/**
	 * The maximum PDU size gives the size in bytes of the largest PDU (protocol
	 * data unit) in this hint stream.
	 */
	public function getMaxPDUsize() : Int
	{
		return maxPDUsize;
	}

	/**
	 * The average PDU size gives the average size of a PDU over the entire
	 * presentation.
	 */
	public function getAveragePDUsize() : Int
	{
		return avgPDUsize;
	}

	/**
	 * The maximum bitrate gives the maximum rate in bits/second over any window
	 * of one second.
	 */
	public function getMaxBitrate() : Int
	{
		return maxBitrate;
	}

	/**
	 * The average bitrate gives the average rate in bits/second over the entire
	 * presentation.
	 */
	public function getAverageBitrate() : Int
	{
		return avgBitrate;
	}
	
}