package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class ChunkOffsetBox extends FullBox
{

	private var chunks : Vector<Int>;

	public function new()
	{
		super("Chunk Offset Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		var len : Int = (type==BoxTypes.CHUNK_LARGE_OFFSET_BOX) ? 8 : 4;
		var entryCount : Int = input.readBytes(4);
		chunks = new Vector<Int>(entryCount);
		left -= 4;

		for (i in 0...entryCount)
		{
			chunks[i] = input.readBytes(len);
			left -= len;
		}
	}

	public function getChunks() : Vector<Int>
	{
		return chunks;
	}
	
}