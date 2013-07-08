package mp4.api;
import flash.Vector;
import haxe.io.BytesData;

/**
 * ...
 * @author Daniel Uranga
 */

class ID3Tag 
{

	private static inline var ID3_TAG = 4801587; //'ID3'
	private static inline var SUPPORTED_VERSION = 4; //id3v2.4
	private var frames : Vector<ID3Frame>;
	private var tag : Int;
	private var flags : Int;
	private var len : Int;

	public function new(input : BytesData)
	{
		frames = new Vector<ID3Frame>();

		//id3v2 header
		tag = (input.readByte()<<16)|(input.readByte()<<8)|input.readByte(); //'ID3'
		var majorVersion : Int = input.readByte();
		input.readByte(); //revision
		flags = input.readByte();
		len = readSynch(input);

		if (tag == ID3_TAG && majorVersion <= SUPPORTED_VERSION)
		{
			if ((flags & 0x40) == 0x40)
			{
				//extended header; TODO: parse
				var extSize : Int = readSynch(input);
				for ( i in 0...(extSize-6) )
					input.readByte();
			}

			//read all id3 frames
			var left : Int = len;
			var frame : ID3Frame;
			while (left > 0)
			{
				frame = new ID3Frame(input);
				frames.push(frame);
				left -= frame.getSize();
			}
		}
	}

	public function getFrames() : Vector<ID3Frame>
	{
		return frames;
	}

	static public function readSynch(input : BytesData) : Int
	{
		var x : Int = 0;
		for (i in 0...4)
		{
			x |= (input.readByte()&0x7F);
		}
		return x;
	}
	
}