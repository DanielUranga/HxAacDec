package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class BitRateBox extends FullBox
{

	private var decodingBufferSize : Int;
	private var maxBitrate : Int;
	private var avgBitrate : Int;

	public function new()
	{
		super("Bitrate Box");
	}

	override public function decode(input : MP4InputStream)
	{
		decodingBufferSize = input.readBytes(4);
		maxBitrate = input.readBytes(4);
		avgBitrate = input.readBytes(4);
		left -= 12;
	}

	/**
	 * Gives the size of the decoding buffer for the elementary stream in bytes.
	 * @return the decoding buffer size
	 */
	public function getDecodingBufferSize() : Int
	{
		return decodingBufferSize;
	}

	/**
	 * Gives the maximum rate in bits/second over any window of one second.
	 * @return the maximum bitrate
	 */
	public function getMaximumBitrate() : Int
	{
		return maxBitrate;
	}

	/**
	 * Gives the average rate in bits/second over the entire presentation.
	 * @return the average bitrate
	 */
	public function getAverageBitrate() : Int
	{
		return avgBitrate;
	}
	
}