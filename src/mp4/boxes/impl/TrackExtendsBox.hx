package mp4.boxes.impl;
import mp4.boxes.FullBox;
import mp4.MP4InputStream;

/**
 * ...
 * @author Daniel Uranga
 */

class TrackExtendsBox extends FullBox
{

	private var trackID : Int;
	private var defaultSampleDescriptionIndex : Int;
	private var defaultSampleDuration : Int;
	private var defaultSampleSize : Int;
	private var defaultSampleFlags : Int;

	public function new()
	{
		super("Track Extends Box");
	}

	override public function decode(input : MP4InputStream)
	{
		super.decode(input);

		trackID = input.readBytes(4);
		defaultSampleDescriptionIndex = input.readBytes(4);
		defaultSampleDuration = input.readBytes(4);
		defaultSampleSize = input.readBytes(4);
		/* 6 bits reserved
		 * 2 bits sampleDependsOn
		 * 2 bits sampleIsDependedOn
		 * 2 bits sampleHasRedundancy
		 * 3 bits samplePaddingValue
		 * 1 bit sampleIsDifferenceSample
		 * 16 bits sampleDegradationPriority
		 */
		defaultSampleFlags = input.readBytes(4);

		left -= 20;
	}

	/**
	 * The track ID identifies the track; this shall be the track ID of a track
	 * in the Movie Box.
	 *
	 * @return the track ID
	 */
	public function getTrackID() : Int
	{
		return trackID;
	}

	/**
	 * The default sample description index used in the track fragments.
	 *
	 * @return the default sample description index
	 */
	public function getDefaultSampleDescriptionIndex() : Int
	{
		return defaultSampleDescriptionIndex;
	}

	/**
	 * The default sample duration used in the track fragments.
	 *
	 * @return the default sample duration
	 */
	public function getDefaultSampleDuration() : Int
	{
		return defaultSampleDuration;
	}

	/**
	 * The default sample size used in the track fragments.
	 *
	 * @return the default sample size
	 */
	public function getDefaultSampleSize() : Int
	{
		return defaultSampleSize;
	}

	/**
	 * The default 'sample depends on' value as defined in the
	 * SampleDependencyTypeBox.
	 *
	 * @see SampleDependencyTypeBox#getSampleDependsOn()
	 * @return the default 'sample depends on' value
	 */
	public function getSampleDependsOn() : Int
	{
		return (defaultSampleFlags>>24)&3;
	}

	/**
	 * The default 'sample is depended on' value as defined in the
	 * SampleDependencyTypeBox.
	 *
	 * @see SampleDependencyTypeBox#getSampleIsDependedOn()
	 * @return the default 'sample is depended on' value
	 */
	public function getSampleIsDependedOn() : Int
	{
		return (defaultSampleFlags>>22)&3;
	}

	/**
	 * The default 'sample has redundancy' value as defined in the
	 * SampleDependencyBox.
	 *
	 * @see SampleDependencyTypeBox#getSampleHasRedundancy()
	 * @return the default 'sample has redundancy' value
	 */
	public function getSampleHasRedundancy() : Int
	{
		return (defaultSampleFlags>>20)&3;
	}

	/**
	 * The default padding value as defined in the PaddingBitBox.
	 *
	 * @see PaddingBitBox#getPad1()
	 * @return the default padding value
	 */
	public function getSamplePaddingValue() : Int
	{
		return (defaultSampleFlags>>17)&7;
	}

	public function isSampleDifferenceSample() : Bool
	{
		return ((defaultSampleFlags>>16)&1)==1;
	}

	/**
	 * The default degradation priority for the samples.
	 * @return the default degradation priority
	 */
	public function getSampleDegradationPriority() : Int
	{
		return defaultSampleFlags&0xFFFF;
	}
	
}