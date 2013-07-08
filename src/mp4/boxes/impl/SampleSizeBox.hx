package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleSizeBox extends FullBox
{

	private var sampleCount : Int;
	private var sampleSizes : Vector<Int>;

	public function new()
	{
		super("Sample Size Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var compact : Bool = (type==BoxTypes.COMPACT_SAMPLE_SIZE_BOX);

		var sampleSize : Int;
		if (compact)
		{
			input.skipBytes(3);
			sampleSize = input.read();
		}
		else sampleSize = input.readBytes(4);

		sampleCount = input.readBytes(4);
		sampleSizes = new Vector<Int>(sampleCount);
		left -= 8;

		if (compact)
		{
			//compact: sampleSize can be 4, 8 or 16 bits
			if (sampleSize == 4)
			{
				var x : Int;
				var i : Int = 0;
				while (i < sampleCount)
				{
					x = input.read();
					sampleSizes[i] = (x>>4)&0xF;
					sampleSizes[i + 1] = x & 0xF;
					i += 2;
				}
				left -= Std.int(sampleCount/2);
			}
			else readSizes(input, Std.int(sampleSize/8));
		}
		else if(sampleSize==0) readSizes(input, 4);
		else //Arrays.fill(sampleSizes, sampleSize);
		{
			for ( i in sampleSizes )
				i = sampleSize;
		}
	}

	private function readSizes(input : MP4InputStream, len : Int)
	{
		for (i in 0...sampleCount)
		{
			sampleSizes[i] = input.readBytes(len);
		}
		left -= sampleCount*len;
	}

	public function getSampleCount() : Int
	{
		return sampleCount;
	}

	public function getSampleSizes() : Vector<Int>
	{
		return sampleSizes;
	}
	
}