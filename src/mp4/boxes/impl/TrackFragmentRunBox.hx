package mp4.boxes.impl;
import flash.Vector;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackFragmentRunBox extends FullBox
{

	private var sampleCount : Int;
	private var dataOffsetPresent : Bool;
	private var firstSampleFlagsPresent : Bool;
	private var dataOffset : Int;
	private var firstSampleFlags : Int;
	private var sampleDurationPresent : Bool;
	private var sampleSizePresent : Bool;
	private var sampleFlagsPresent : Bool;
	private var sampleCompositionTimeOffsetPresent : Bool;
	private var sampleDuration : Vector<Int>;
	private var sampleSize : Vector<Int>;
	private var sampleFlags : Vector<Int>;
	private var sampleCompositionTimeOffset : Vector<Int>;

	public function new()
	{
		super("Track Fragment Run Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		sampleCount = input.readBytes(4);
		left -= 4;

		//optional fields
		dataOffsetPresent = ((flags&1)==1);
		if (dataOffsetPresent)
		{
			dataOffset = input.readBytes(4);
			left -= 4;
		}
		firstSampleFlagsPresent = ((flags&4)==4);
		if (firstSampleFlagsPresent)
		{
			firstSampleFlags = input.readBytes(4);
			left -= 4;
		}

		//all fields are optional
		sampleDurationPresent = ((flags&0x100)==0x100);
		if(sampleDurationPresent) sampleDuration = new Vector<Int>(sampleCount);
		sampleSizePresent = ((flags&0x200)==0x200);
		if(sampleSizePresent) sampleSize = new Vector<Int>(sampleCount);
		sampleFlagsPresent = ((flags&0x400)==0x400);
		if(sampleFlagsPresent) sampleFlags = new Vector<Int>(sampleCount);
		sampleCompositionTimeOffsetPresent = ((flags&0x800)==0x800);
		if (sampleCompositionTimeOffsetPresent) sampleCompositionTimeOffset = new Vector<Int>(sampleCount);

		var i : Int = 0;
		while ( i<sampleCount&&left>0 )
		{
			if (sampleDurationPresent)
			{
				sampleDuration[i] = input.readBytes(4);
				left -= 4;
			}
			if (sampleSizePresent)
			{
				sampleSize[i] = input.readBytes(4);
				left -= 4;
			}
			if (sampleFlagsPresent)
			{
				sampleFlags[i] = input.readBytes(4);
				left -= 4;
			}
			if (sampleCompositionTimeOffsetPresent)
			{
				sampleCompositionTimeOffset[i] = input.readBytes(4);
				left -= 4;
			}
			i++;
		}
	}

	public function getSampleCount() : Int
	{
		return sampleCount;
	}

	public function isDataOffsetPresent() : Bool
	{
		return dataOffsetPresent;
	}

	public function getDataOffset() : Int
	{
		return dataOffset;
	}

	public function isFirstSampleFlagsPresent() : Bool
	{
		return firstSampleFlagsPresent;
	}

	public function getFirstSampleFlags() : Int
	{
		return firstSampleFlags;
	}

	public function isSampleDurationPresent() : Bool
	{
		return sampleDurationPresent;
	}

	public function getSampleDuration() : Vector<Int>
	{
		return sampleDuration;
	}

	public function isSampleSizePresent() : Bool
	{
		return sampleSizePresent;
	}

	public function getSampleSize() : Vector<Int>
	{
		return sampleSize;
	}

	public function isSampleFlagsPresent() : Bool
	{
		return sampleFlagsPresent;
	}

	public function getSampleFlags() : Vector<Int>
	{
		return sampleFlags;
	}

	public function isSampleCompositionTimeOffsetPresent() : Bool
	{
		return sampleCompositionTimeOffsetPresent;
	}

	public function getSampleCompositionTimeOffset() : Vector<Int>
	{
		return sampleCompositionTimeOffset;
	}
	
}