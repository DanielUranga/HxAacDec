package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class SampleToChunkEntry
{
	private var firstChunk : Int;
	private var samplesPerChunk : Int;
	private var sampleDescriptionIndex : Int;

	public function new(firstChunk : Int, samplesPerChunk : Int, sampleDescriptionIndex : Int)
	{
		this.firstChunk = firstChunk;
		this.samplesPerChunk = samplesPerChunk;
		this.sampleDescriptionIndex = sampleDescriptionIndex;
	}

	public function getFirstChunk() : Int
	{
		return firstChunk;
	}

	public function getSampleDescriptionIndex() : Int
	{
		return sampleDescriptionIndex;
	}

	public function getSamplesPerChunk() : Int
	{
		return samplesPerChunk;
	}
}
 
class SampleToChunkBox extends FullBox
{

	private var entries : Vector<SampleToChunkEntry>;

	public function new()
	{
		super("Sample To Chunk Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);
		
		var entryCount : Int = input.readBytes(4);
		entries = new Vector<SampleToChunkEntry>(entryCount);
		left -= 4;

		var firstChunk : Int;
		var samplesPerChunk : Int;
		var sampleDescriptionIndex : Int;
		for (i in 0...entryCount)
		{
			firstChunk = input.readBytes(4);
			samplesPerChunk = input.readBytes(4);
			sampleDescriptionIndex = input.readBytes(4);
			entries[i] = new SampleToChunkEntry(firstChunk, samplesPerChunk, sampleDescriptionIndex);
			left -= 12;
		}
	}

	public function getEntries() : Vector<SampleToChunkEntry>
	{
		return entries;
	}
	
}