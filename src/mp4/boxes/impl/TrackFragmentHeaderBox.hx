package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackFragmentHeaderBox extends FullBox
{

	private var trackID : Int;
	private var baseDataOffsetPresent : Bool;
	private var sampleDescriptionIndexPresent : Bool;
	private var defaultSampleDurationPresent : Bool;
	private var defaultSampleSizePresent : Bool;
	private var defaultSampleFlagsPresent : Bool;
	private var durationIsEmpty : Bool;
	private var baseDataOffset : Int;
	private var sampleDescriptionIndex : Int;
	private var defaultSampleDuration : Int;
	private var defaultSampleSize : Int;
	private var defaultSampleFlags : Int;

	public function new()
	{
		super("Track Fragment Header Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		trackID = input.readBytes(4);

		//optional fields
		baseDataOffsetPresent = ((flags&1)==1);
		if (baseDataOffsetPresent)
		{
			baseDataOffset = input.readBytes(8);
			left -= 8;
		}
		else baseDataOffset = 0;

		sampleDescriptionIndexPresent = ((flags&2)==2);
		if (sampleDescriptionIndexPresent)
		{
			sampleDescriptionIndex = input.readBytes(4);
			left -= 4;
		}
		else sampleDescriptionIndex = 0;

		defaultSampleDurationPresent = ((flags&8)==8);
		if (defaultSampleDurationPresent)
		{
			defaultSampleDuration = defaultSampleDurationPresent ? input.readBytes(4) : 0;
			left -= 4;
		}
		else defaultSampleDuration = 0;

		defaultSampleSizePresent = ((flags&16)==16);
		if (defaultSampleSizePresent)
		{
			defaultSampleSize = defaultSampleSizePresent ? input.readBytes(4) : 0;
			left -= 4;
		}
		else defaultSampleSize = 0;
		
		defaultSampleFlagsPresent = ((flags&32)==32);
		if (defaultSampleFlagsPresent)
		{
			defaultSampleFlags = defaultSampleFlagsPresent ? input.readBytes(4) : 0;
			left -= 4;
		}
		else defaultSampleFlags = 0;

		durationIsEmpty = ((flags&0x10000)==0x10000);
	}

	public function getTrackID() : Int
	{
		return trackID;
	}

	public function isBaseDataOffsetPresent() : Bool
	{
		return baseDataOffsetPresent;
	}

	public function getBaseDataOffset() : Int
	{
		return baseDataOffset;
	}

	public function isSampleDescriptionIndexPresent() : Bool
	{
		return sampleDescriptionIndexPresent;
	}

	public function getSampleDescriptionIndex() : Int
	{
		return sampleDescriptionIndex;
	}

	public function isDefaultSampleDurationPresent() : Bool
	{
		return defaultSampleDurationPresent;
	}

	public function getDefaultSampleDuration() : Int
	{
		return defaultSampleDuration;
	}

	public function isDefaultSampleSizePresent() : Bool
	{
		return defaultSampleSizePresent;
	}

	public function getDefaultSampleSize() : Int
	{
		return defaultSampleSize;
	}

	public function isDefaultSampleFlagsPresent() : Bool
	{
		return defaultSampleFlagsPresent;
	}

	public function getDefaultSampleFlags() : Int
	{
		return defaultSampleFlags;
	}

	public function isDurationIsEmpty() : Bool
	{
		return durationIsEmpty;
	}
	
}