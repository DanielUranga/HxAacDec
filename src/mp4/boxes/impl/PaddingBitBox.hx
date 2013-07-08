package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class PaddingBitBox extends FullBox
{

	private var pad1 : Vector<Int>;
	private var pad2 : Vector<Int>;

	public function new()
	{
		super("Padding Bit Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var sampleCount : Int = Std.int((input.readBytes(4)+1)/2);
		left -= 4;
		pad1 = new Vector<Int>(sampleCount);
		pad2 = new Vector<Int>(sampleCount);

		var b : Int;
		for (i in 0...sampleCount)
		{
			b = input.read();
			//1 bit reserved
			//3 bits pad1
			pad1[i] = (b>>4)&7;
			//1 bit reserved
			//3 bits pad2
			pad2[i] = b&7;
		}
		left -= sampleCount;
	}

	/**
	 * Integer values from 0 to 7, indicating the number of bits at the end of
	 * sample (i*2)+1.
	 */
	public function getPad1() : Vector<Int>
	{
		return pad1;
	}

	/**
	 * Integer values from 0 to 7, indicating the number of bits at the end of
	 * sample (i*2)+2.
	 */
	public function getPad2() : Vector<Int>
	{
		return pad2;
	}
	
}